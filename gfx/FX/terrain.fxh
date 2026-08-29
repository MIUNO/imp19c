Includes = {
	"jomini/jomini_gradient_borders.fxh"
}

PixelShader =
{
	TextureSampler HeightmapToFlatmap
	{
		Index = 17
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "map_data/heightmap_flatmap.png"
		srgb = yes
	}
	TextureSampler RiversToFlatmap
	{
		Index = 18
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "map_data/rivers.png"
		srgb = yes
	}
	Code
	[[
		float3 ApplyGradientBorderColor( in float3 BaseColor, inout float3 BorderColor, in float BlendAmount )
		{
			float Brightness = saturate( dot( BaseColor, float3( 0.2125, 0.7154, 0.0721 ) ) );
			float Mask = ( 1.0f - Brightness );
			
			BorderColor = RGBtoHSV( BorderColor );
			BorderColor.y *= 0.88f;
			BorderColor = HSVtoRGB( BorderColor );
			
			float3 Combined = lerp( BaseColor, BorderColor, Mask );
			float3 SoftLight = Combined + BaseColor * ( 1.0f - ((1.0f-BaseColor)*(1.0f-BorderColor)) - Combined );
			
			return lerp( BaseColor, SoftLight, BlendAmount );
		}

		void ApplyTerrainColor( inout float3 Diffuse, inout float3 FlatMap, inout float3 BorderColor, out float BorderPostLightingBlend, in float2 ColorMapCoords )
		{
			float BorderPreLightingBlend;
			GetBorderColorAndBlend( ColorMapCoords, BorderColor, BorderPreLightingBlend, BorderPostLightingBlend );
			Diffuse = ApplyGradientBorderColor( Diffuse, BorderColor, BorderPreLightingBlend );

			#ifdef TERRAIN_FLAT_MAP_LERP
				FlatMap = lerp( FlatMap, BorderColor, saturate( BorderPreLightingBlend + BorderPostLightingBlend ) );
			#endif
		}

		float4 MixLayer(float Value, float Color)
		{
			float MinValue = Value;
			float MaxValue = MinValue + 1;
			float Min = (MinValue * 100 / 255) * 0.001;
			// float Max = 0.01765;
			float Max = (MaxValue * 100 / 255) * 0.001;
			float Alpha = smoothstep(Min, Max, clamp(Color, Min, Max));
			return Alpha;
		}
		float4 FlatTerrainShader( in float3 WorldSpacePos, in float2 ColorMapCoords, in PdxTextureSampler2D FlatMapTex )
		{	
			// float3 FlatMap = PdxTex2D( FlatMapTex, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb;

			// #ifdef TERRAIN_COLOR_OVERLAY
			// 	float3 ColorOverlay;
			// 	float PreLightingBlend;
			// 	float PostLightingBlend;
			// 	GetBorderColorAndBlend( ColorMapCoords, ColorOverlay, PreLightingBlend, PostLightingBlend );

			// 	FlatMap = lerp( FlatMap, ColorOverlay, saturate( PreLightingBlend + PostLightingBlend ) );
			// #endif
			
			// float3 FinalColor = FlatMap;
			
			// #ifdef TERRAIN_COLOR_OVERLAY
			// 	float4 HighlightColor = BilinearColorSampleAtOffset( ColorMapCoords, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
			// 	FinalColor.rgb = lerp( FinalColor.rgb, HighlightColor.rgb, HighlightColor.a );
			// #endif

			
			// #ifdef TERRAIN_DEBUG
			// 	TerrainDebug( FinalColor, WorldSpacePos );
			// #endif
			
			//DebugReturn( FinalColor, lightingProperties, ShadowTerm );

			float2 UV = float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y );
			float4 Color = PdxTex2D( HeightmapToFlatmap, UV );

			float3 GroundColor = float3( 0.824, 0.769, 0.663 );
			float3 WaterColor = float3( 0.761, 0.765, 0.682 );
			float3 BorderColor = float3( 0.239, 0.212, 0.169 );

			float BaseValue = 60;

			float4 FinalColor = float4( 0.0, 0.0, 0.0, 1.0 );
			float BaseAlpha = MixLayer(BaseValue, Color.r);

			float3 RiverColor = PdxTex2D( RiversToFlatmap, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb;
			float3 RiverBase = float3(1.0, 1.0, 1.0) - RiverColor;
			float RiverAlpha = smoothstep(0.0, 1.0, RiverBase.r + RiverBase.g + RiverBase.b);
			FinalColor = lerp(float4( GroundColor, 1.0 ), float4( BorderColor, 1.0 ), (1 - BaseAlpha) + RiverAlpha );

			FinalColor = lerp(float4( WaterColor, 1.0 ), float4( FinalColor.rgb, 1.0 ), BaseAlpha );



			// #ifdef TERRAIN_COLOR_OVERLAY
			// 	float3 ColorOverlay;
			// 	float PreLightingBlend;
			// 	float PostLightingBlend;
			// 	GetBorderColorAndBlend( ColorMapCoords, ColorOverlay, PreLightingBlend, PostLightingBlend );

			// 	FinalColor.rgb = lerp( FinalColor.rgb, ColorOverlay, saturate( PreLightingBlend + PostLightingBlend ) );
			// #endif

			// #ifdef TERRAIN_COLOR_OVERLAY
			// 	float4 HighlightColor = BilinearColorSampleAtOffset( ColorMapCoords, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
			// 	FinalColor.rgb = lerp( FinalColor.rgb, HighlightColor.rgb, HighlightColor.a );
			// #endif

			// FinalColor = lerp(float4( WaterColor, 1.0 ), float4( FinalColor.rgb, 1.0 ), BaseAlpha );

			return float4( FinalColor.rgb, 1 );
		}
	]]
}
