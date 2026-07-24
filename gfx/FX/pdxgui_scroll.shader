Includes = {
	"cw/pdxgui.fxh"
	"cw/pdxgui_sprite.fxh"
	"standardfuncsgfx.fxh"
}

VertexShader =
{
	MainCode VertexShader
	{
		Input = "VS_INPUT_PDX_GUI"
		Output = "VS_OUTPUT_PDX_GUI"
		Code
		[[
			PDX_MAIN
			{
				return PdxGuiDefaultVertexShader( Input );
			}
		]]
	}
}


PixelShader =
{
	MainCode PixelShader
	{
		TextureSampler Texture
		{
			Ref = PdxTexture0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
		}
	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			float2 rotateUV(float2 UV, float rotation)
			{
			    float mid_x = 0.5;
			    float mid_y = 1.0;
			    return float2(
			        cos(rotation) * (UV.x - mid_x) + sin(rotation) * (UV.y - mid_y) + mid_x,
			        cos(rotation) * (UV.y - mid_y) - sin(rotation) * (UV.x - mid_x) + mid_y
			    );
			}
			PDX_MAIN
			{
				float2 UV = Input.UV0;
				float4 OutColor = SampleImageSprite( Texture, UV );
				#if defined( SCROLL )
					float WaveSize = 20.0;
					float WaveSpeed = 0.1;
					#if defined( SCROLL_1 )
						WaveSize = 17.5;
						WaveSpeed = -0.05;
					#endif
					#if defined( SCROLL_2 )
						WaveSpeed = -0.1;
					#endif
				    float Wave = sin((UV.x + GlobalTime * WaveSpeed) * WaveSize) * 0.1;
					#if defined( SCROLL_1 )
						UV.y -= 0.1;
					#endif
					#if defined( SCROLL_2 )
						UV.y -= 0.3;
					#endif

				    OutColor = SampleImageSprite( Texture, float2(UV.x, UV.y+Wave) );
				#endif

				#if defined( ROTATE_1 )
				    UV = rotateUV( UV, sin((UV.x + GlobalTime * 20.0) * 0.1) * 0.1);
				    // UV.y = UV.y + 0.5;
					OutColor = SampleImageSprite( Texture, UV );
				#endif

				OutColor *= Input.Color;

				#if defined( SCROLL_1 )
					OutColor.rgb *= float3(0.8, 0.8, 0.8);
				#endif
				#if defined( ROTATE_1 )
					OutColor.rgb *= float3(0.9, 0.9, 0.9);
				#endif

				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif

			    return OutColor;
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}

BlendState BlendStateNoAlpha
{
	BlendEnable = no
}

BlendState PreMultipliedAlpha
{
	BlendEnable = yes
	SourceBlend = "ONE"
	DestBlend = "INV_SRC_ALPHA"
}

DepthStencilState DepthStencilState
{
	DepthEnable = no
}


Effect PdxGuiDefault
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}
Effect PdxGuiDefaultDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "SCROLL" "DISABLED" }
}

Effect test_PixelShader
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	Defines = { "SCROLL" "SCROLL_1" }
}
Effect test_PixelShaderDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "SCROLL" "SCROLL_1" "DISABLED" }
}
Effect test2_PixelShader
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	Defines = { "SCROLL" "SCROLL_2" }
}
Effect test2_PixelShaderDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "SCROLL_2" "DISABLED" }
}
Effect test3_PixelShader
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	Defines = { "ROTATE_1" }
}
Effect test3_PixelShaderDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "ROTATE_1" "DISABLED" }
}