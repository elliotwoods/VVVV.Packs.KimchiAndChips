//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

struct vsInput
{
    float4 posObject : POSITION;
    float4 normalObject : NORMAL;
};

struct psInput
{
    float4 posScreen : SV_Position;
	float4 normalWorld : TEXCOORD0;
};

cbuffer cbPerDraw : register(b0)
{
	float4x4 tVP : VIEWPROJECTION;
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4x4 NormalsTransform;
	float4x4 tWIT: WORLDINVERSETRANSPOSE;
};

psInput VS(vsInput input)
{
	psInput output;
	output.posScreen = mul(input.posObject,mul(tW,tVP));
	
	float4 normals = input.normalObject;
	normals.xyz = mul(normals.xyz, (float3x3) tWIT);
	normals.xyz = normalize(normals.xyz);
	normals.w = 1.0f;
	
	normals = mul(normals, NormalsTransform);
	normals /= normals.w;
	
	output.normalWorld = normals;
	return output;
}


float4 PS(psInput input): SV_Target
{
    return input.normalWorld;
}

technique11 Normals 
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}
