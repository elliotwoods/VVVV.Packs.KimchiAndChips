//@author: elliotwoods
//@help: draw xyz in world as output rgb
//@tags: 
//@credits: 

cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;	
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4x4 Transform;
};

struct VS_IN
{
	float4 PosO : POSITION;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 PosW: TEXCOORD0;
    float4 PosO: TEXCOORD1;
};

vs2ps VS(VS_IN input)
{
    vs2ps output;
	output.PosW = mul(input.PosO, tW);
	output.PosWVP = mul(output.PosW, tVP);
	output.PosO = mul(output.PosW, Transform);
    return output;
}




float4 PS(vs2ps In): SV_Target
{
	In.PosO /= In.PosO.w;
    float4 col = In.PosO;
    return col;
}





technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




