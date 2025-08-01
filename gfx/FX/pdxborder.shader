Includes = {
	"cw/camera.fxh"
	"jomini/jomini_fog.fxh"
	"fog_of_war.fxh"
	"standardfuncsgfx.fxh"
}


ConstantBuffer( 1 )
{
	float3		Scale;
	float       vHeightOffset;
}

ConstantBuffer( 2 )
{
	float		vAlpha;
}

VertexStruct VS_INPUT_PDX_BORDER
{
	float3 Position			: TEXCOORD0;
	float2 UV				: TEXCOORD1;
};

VertexStruct VS_OUTPUT_PDX_BORDER
{
	float4 Position			: PDX_POSITION;
	float3 WorldSpacePos	: TEXCOORD0;
	float2 UV				: TEXCOORD1;
};


VertexShader =
{
	MainCode VertexShader
	{
		Input = "VS_INPUT_PDX_BORDER"
		Output = "VS_OUTPUT_PDX_BORDER"
		Code
		[[			
			PDX_MAIN
			{
				VS_OUTPUT_PDX_BORDER Out;
				
				float3 position = Input.Position * Scale;
				position.y = lerp( position.y, FlatMapHeight, FlatMapLerp );
				position.y += vHeightOffset;
				
				Out.WorldSpacePos = position;
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( position, 1.0 ) );
				Out.UV = Input.UV;
			
				return Out;
			}
		]]
	}
}


PixelShader =
{	
	TextureSampler BorderTexture
	{
		Index = 0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Clamp"
	}
	TextureSampler FogOfWarAlpha
	{
		Ref = JominiFogOfWar
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}

	MainCode PixelShader
	{
		Input = "VS_OUTPUT_PDX_BORDER"
		Output = "PDX_COLOR"
		Code
		[[			
			PDX_MAIN
			{
				float2 UV = Input.UV;
				float ZoomSepMix = 275;
				float ZoomSepMax = 1400;
				UV.y *= ( 1 - smoothstep(ZoomSepMix, ZoomSepMax, CameraPosition.y) * 0.8);
				UV.y += smoothstep(ZoomSepMix, ZoomSepMax, CameraPosition.y) * 0.3;
				// UV.x = UV.x * ( 1 - smoothstep(ZoomSepMix, ZoomSepMax, CameraPosition.y) * 0.7);
				// UV.x = UV.x + smoothstep(ZoomSepMix, ZoomSepMax, CameraPosition.y) * 0.3;

				float4 Diffuse = PdxTex2D( BorderTexture, UV );

				#ifdef PULSATE
					Diffuse.rgb *= 1.0f + pow( sin( GlobalTime * 2 ) * 0.5f + 0.5f, 1.5 ) * 3.0f;
				#endif
				
				Diffuse.rgb = ApplyFogOfWar( Diffuse.rgb, Input.WorldSpacePos, FogOfWarAlpha );
				Diffuse.rgb = ApplyDistanceFog( Diffuse.rgb, Input.WorldSpacePos );
				
				Diffuse.a *= vAlpha;
				
				return Diffuse;
			}
		]]
	}
}

BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	WriteMask = "RED|GREEN|BLUE"
}

RasterizerState RasterizerState
{
	#DepthBias = -50
	DepthBias = -50000
	SlopeScaleDepthBias = -2
}

DepthStencilState DepthStencilState
{
	DepthWriteEnable = no
	StencilEnable = yes
	FrontStencilFunc = not_equal
	StencilRef = 1
}

Effect PdxBorder
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}
Effect PdxBorderSelected
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	Defines = { "PULSATE" }
}
