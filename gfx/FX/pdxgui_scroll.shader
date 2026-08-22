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
				float Time = GlobalTime;

				#ifdef STOP
					Time = 3.0;
				#endif

				#ifdef SCROLL
					float WaveSize = 20.0;
					float WaveSpeed = 0.1;

					#ifdef SCROLL_1
						WaveSize = 17.5;
						WaveSpeed = -0.05;
					#endif
					#ifdef SCROLL_2
						WaveSpeed = -0.1;
					#endif
				    float Wave = sin((UV.x + Time * WaveSpeed) * WaveSize) * 0.1;
					#ifdef SCROLL_1
						UV.y -= 0.1;
					#endif
					#ifdef SCROLL_2
						UV.y -= 0.3;
					#endif

				    OutColor = SampleImageSprite( Texture, float2(UV.x, UV.y+Wave) );
				#endif

				#ifdef ROTATE_1
				    UV = rotateUV( UV, sin((UV.x + Time * 20.0) * 0.1) * 0.1);
					OutColor = SampleImageSprite( Texture, UV );
				#endif

				OutColor *= Input.Color;

				#ifdef DARK_3
					OutColor.rgb *= float3(0.7, 0.7, 0.7);
				#endif
				#ifdef DARK_2
					OutColor.rgb *= float3(0.8, 0.8, 0.8);
				#endif
				#ifdef DARK_1
					OutColor.rgb *= float3(0.9, 0.9, 0.9);
				#endif

				// #ifdef DISABLED
				// 	OutColor.rgb = DisableColor( OutColor.rgb );
				// #endif

				#ifdef DISABLED
				 	OutColor.rgb = DisableColor( OutColor.rgb );
				#endif

				#ifdef DISABLED_ANIMATION
					OutColor.a = 0.0;
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

Effect dark_1
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	Defines = { "DARK_1" }
}
Effect dark_1Disabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "DARK_1" "DISABLED" }
}
Effect dark_2
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	Defines = { "DARK_2" }
}
Effect dark_2Disabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "DARK_2" "DISABLED" }
}
Effect dark_3
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	Defines = { "DARK_3" }
}
Effect dark_3Disabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "DARK_3" "DISABLED" }
}

Effect scroll_1
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	Defines = { "SCROLL" "SCROLL_1" "DARK_2" }
}
Effect scroll_1Disabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "SCROLL" "SCROLL_1" "DARK_2" "DISABLED_ANIMATION" }
}
Effect scroll_2
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	Defines = { "SCROLL" "SCROLL_2" }
}
Effect scroll_2Disabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "SCROLL_2" "DISABLED_ANIMATION" }
}
Effect rotate_1
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	Defines = { "ROTATE_1" "DARK_1" }
}
Effect rotate_1Disabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "ROTATE_1" "DARK_1" "DISABLED_ANIMATION" }
}

Effect scroll_1_stop
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	Defines = { "SCROLL" "SCROLL_1" "DARK_2" "STOP" }
}
Effect scroll_1_stopDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "SCROLL" "SCROLL_1" "DARK_2" "STOP" "DISABLED_ANIMATION" }
}
Effect scroll_2_stop
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	Defines = { "SCROLL" "SCROLL_2" "STOP" }
}
Effect scroll_2_stopDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "SCROLL_2" "STOP" "DISABLED_ANIMATION" }
}
Effect rotate_1_stop
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	Defines = { "ROTATE_1" "DARK_1" "STOP" }
}
Effect rotate_1_stopDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "ROTATE_1" "DARK_1" "STOP" "DISABLED_ANIMATION" }
}