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
		File = "gfx/map/flatmap/heightmap_flatmap.png"
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
	TextureSampler LakesToFlatmap
	{
		Index = 19
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/flatmap/flatmap_lakes.png"
		srgb = yes
	}
	TextureSampler BordersToFlatmap
	{
		Index = 20
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/flatmap/flatmap_alpha.png"
		srgb = yes
	}
	TextureSampler SymbolsToFlatmap
	{
		Index = 21
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/flatmap/flatmap_deco.png"
		srgb = yes
	}
	TextureSampler GroundToFlatmap
	{
		Index = 24
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/flatmap/ground.png"
		srgb = yes
	}
	TextureSampler WaterToFlatmap
	{
		Index = 25
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/flatmap/water.png"
		srgb = yes
	}
	TextureSampler BorderToFlatmap
	{
		Index = 26
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/flatmap/border.png"
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
		float4 FlatTerrainShader( in float3 WorldSpacePos, in float2 ColorMapCoords )
		{	
			// float3 FlatMap = PdxTex2D( FlatMapTex, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb;

			float2 UV = float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y );
			float4 Color = PdxTex2D( HeightmapToFlatmap, UV );

			// float3 GroundColor = float3( 0.824, 0.769, 0.663 );
			float3 GroundColor = PdxTex2D( GroundToFlatmap, UV ).rgb;
			// float3 WaterColor = float3( 0.761, 0.765, 0.682 );
			float3 WaterColor = PdxTex2D( WaterToFlatmap, UV ).rgb;
			// float3 BorderColor = float3( 0.239, 0.212, 0.169 );
			float3 BorderColor = PdxTex2D( BorderToFlatmap, UV ).rgb;

			float BaseValue = 60;

			float4 FinalColor = float4( 0.0, 0.0, 0.0, 1.0 );
			float BaseAlpha = MixLayer(BaseValue, Color.r);



			float LakeAlpha = PdxTex2D( LakesToFlatmap, UV ).r;
			BaseAlpha = BaseAlpha - LakeAlpha;
			float3 RiverColor = PdxTex2D( RiversToFlatmap, UV ).rgb;
			float3 RiverBase = float3(1.0, 1.0, 1.0) - RiverColor;
			// float RiverAlpha = smoothstep(0.0, 1.0, RiverBase.r + RiverBase.g + RiverBase.b);
			float RiverAlpha = (RiverBase.r + RiverBase.g + RiverBase.b) * 0.5;
			FinalColor = lerp(float4( GroundColor, 1.0 ), float4( lerp( GroundColor, BorderColor, 0.5 ), 1.0 ), (1 - BaseAlpha) + RiverAlpha );

			FinalColor = lerp(float4( WaterColor, 1.0 ), float4( FinalColor.rgb, 1.0 ), BaseAlpha );

			float4 Borders = PdxTex2D( BordersToFlatmap, UV );
			Borders.a = smoothstep(0.0, 1.0, Borders.r + Borders.g + Borders.b);
			Borders = float4( BorderColor, Borders.a );
			FinalColor = lerp(float4( FinalColor.rgb, 1.0 ), float4( Borders.rgb, 1.0 ), Borders.a );

			#ifdef TERRAIN_COLOR_OVERLAY
				float3 ColorOverlay;
				float PreLightingBlend;
				float PostLightingBlend;
				GetBorderColorAndBlend( ColorMapCoords, ColorOverlay, PreLightingBlend, PostLightingBlend );

				FinalColor.rgb = lerp( FinalColor.rgb, ColorOverlay, saturate( PreLightingBlend + PostLightingBlend ) );
			#endif

			#ifdef TERRAIN_COLOR_OVERLAY
				float4 HighlightColor = BilinearColorSampleAtOffset( ColorMapCoords, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
				FinalColor.rgb = lerp( FinalColor.rgb, HighlightColor.rgb, HighlightColor.a );
			#endif

			float WaterLayer01 = MixLayer(35, Color.r) * 0.025;
			float WaterLayer02 = MixLayer(20, Color.r) * 0.025;
			float WaterLayer03 = MixLayer(5, Color.r) * 0.025;
			float3 WaterBase = WaterColor + WaterLayer01;
			WaterBase = WaterBase + WaterLayer02;
			WaterBase = WaterBase + WaterLayer03;

			FinalColor = lerp(float4( WaterBase, 1.0 ), float4( FinalColor.rgb, 1.0 ), BaseAlpha );

			float4 Symbols = PdxTex2D( SymbolsToFlatmap, UV );
			Symbols.a = smoothstep(0.0, 1.0, Symbols.r + Symbols.g + Symbols.b);
			Symbols = float4( BorderColor, Symbols.a );
			FinalColor = lerp(float4( FinalColor.rgb, 1.0 ), float4( Symbols.rgb, 1.0 ), Symbols.a );

			#ifdef TERRAIN_DEBUG
				TerrainDebug( FinalColor, WorldSpacePos );
			#endif

			// DebugReturn( FinalColor, lightingProperties, ShadowTerm );
			return float4( FinalColor.rgb, 1 );
		}
	]]
}
