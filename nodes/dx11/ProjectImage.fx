//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits: 

Texture2D colorTexture <string uiname="Color Texture";>;
Texture2D worldTexture <string uiname="World From Projector";>;

SamplerState linearSampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;	
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4x4 tProjector <string uiname="Projector ViewProjection";>;
	float4 cAmb <bool color=true;String uiname="Ambient Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float shadowThreshold <string uiname="Shadow Threshold";> = 0.01f;
};

struct VS_IN
{
	float4 PosO : POSITION;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
	float4 PosW: TEXCOORD1;
};

vs2ps VS(VS_IN input)
{
    vs2ps output;
	float4 PosW = mul(input.PosO, tW);
	PosW /= PosW.w;
	output.PosW = PosW;
    output.PosWVP  = mul(PosW,tVP);
	
	float4 TexCd = mul(PosW, tProjector);
	TexCd /= TexCd.w;
	TexCd.xy += 1.0f;
	TexCd.xy /= 2.0f;
	TexCd.y = 1.0f - TexCd.y;
    output.TexCd = TexCd;
	
    return output;
}




float4 PS(vs2ps In): SV_Target
{
    //float4 col = texture2d.Sample(linearSampler,In.TexCd.xy) * cAmb;
	
	float2 projTexCd = In.TexCd.xy;
	float4 pixelXYZ = worldTexture.Sample(linearSampler, projTexCd);
	pixelXYZ /= pixelXYZ.w;
	
	float4 col = colorTexture.Sample(linearSampler, projTexCd);
	
	bool hit = length(pixelXYZ.xyz - In.PosW.xyz)  < shadowThreshold;
	return max(hit * col, cAmb);
}





technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




