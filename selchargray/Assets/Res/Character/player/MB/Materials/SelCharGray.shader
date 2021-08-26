Shader "Custom/SelCharGray"

{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _SSGradientDirection("Gradient Dir",Vector) = (1,0,0,0)
        _SSGradientColor0("Gradient Color0",Color) = (1,0,0,1)
        _SSGradientColor1("Gradient Color1",Color) = (1,0,0,1)
        _ConcealmentColor("conceal Color",Color) = (1,0,0,1)
        _FadeGameplayEffects("gameplay effect",Range(0,1)) = 1
       
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        Pass
        {

            CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
//        #pragma surface surf Standard fullforwardshadows
        #pragma vertex vert
        #pragma fragment surf 

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float4 _MainTex_ST;
        float4 _SSGradientDirection;
        float4 _SSGradientColor0;
        float4 _SSGradientColor1;
        float4 _ConcealmentColor;
        float _FadeGameplayEffects;

        struct VertexInput {
            float4 vertex : POSITION;
            float2 texcoord0 : TEXCOORD0;
            float4 texcoord1 : TEXCOORD1;
            float4 vertexColor : COLOR;
        };
        struct VertexOutput {
            float4 pos : SV_POSITION;
            float2 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 vertexColor : COLOR;
        };
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

       
        VertexOutput vert (VertexInput v) {
            VertexOutput o = (VertexOutput)0;
            float2 uv = TRANSFORM_TEX(v.texcoord0,_MainTex);
            o.uv0.xy = uv;
            o.vertexColor = v.vertexColor;
            o.pos = UnityObjectToClipPos( v.vertex );

            // clip sapce cacl
            float4 cpos = o.pos;
            cpos.y = cpos.y * _ProjectionParams.x;
            float4 temp = float4(0,0,0,0);
            temp.xzw = cpos.xwy * float3(0.5,0.5,0.5);
            o.uv1.zw = cpos.zw;
            o.uv1.xy = temp.zz + temp.xw;
            return o;
        }


        fixed4 surf (VertexOutput input) : SV_Target
        {
            float2 gw = input.uv1.xy /input.uv1.ww;
            gw = gw + float2(-0.5,-0.5);
            gw.x = dot(_SSGradientDirection.xy, gw.xy);
            gw.x = gw.x + 0.5;
            gw.x = clamp(gw.x,0.0,1);

            float4 c0 = (_SSGradientColor1 - _SSGradientColor0)*gw.x + _SSGradientColor0;
            float4 c2 = tex2D (_MainTex, input.uv0) ;
            float4 c1 = (_Color - c2)*_Color.w + c2;
            c1 = (c1 - _ConcealmentColor) * _ConcealmentColor.w + _ConcealmentColor;
            c0 = (c1*c0 - c1)*c0.w + c1;
            c1 = c2 - c0;
            c0.w = 1;
            c1.w = 1;
            fixed4 c = float4(_FadeGameplayEffects, _FadeGameplayEffects,_FadeGameplayEffects,_FadeGameplayEffects) * c1 + c0;

            return c;  

        }

        ENDCG
        }
    }
    FallBack "Diffuse"
}