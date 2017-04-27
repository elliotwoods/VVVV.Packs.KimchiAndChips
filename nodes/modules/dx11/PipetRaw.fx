RWStructuredBuffer<float> Out : BACKBUFFER;
StructuredBuffer<float2> uv <string uiname="UV Buffer";>;
Texture2D tex <string uiname="Texture";>;

int TotalCount=1;
[numthreads(64, 1, 1)]
void CS( uint3 DTid : SV_DispatchThreadID){
	if(DTid.x>=(uint)TotalCount)return;
	
	float2 TexCd=uv[DTid.x];
	
	int2 R;
	tex.GetDimensions(R.x,R.y);
	
	Out[DTid.x] = tex[R * TexCd].r;
}

technique11 Process{pass P0{SetComputeShader(CompileShader(cs_5_0,CS()));}}







