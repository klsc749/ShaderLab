Shader "Custom/RampTexture"{
    Properties{
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        //声明渐变纹理属性_RampTex
        _RampTex("Ramp Tex", 2D) = "white" {}
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
        Subshader{
            Pass {
                Tags { "LightMode" = "ForwardBase"}
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "Lighting.cginc"
                fixed4 _Color;
        //定义与Properties中相应的纹理属性变量
        sampler2D _RampTex;
        float4 _RampTex_ST;
        float4 _Specular;
        float _Gloss;

        struct a2v {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
        };

        struct v2f {
            float4 pos : SV_POSITION;
            float3 worldNormal : TEXCOORD0;
            float3 worldPos : TEXCOORD1;
            float2 uv : TEXCOORD2;
        };


        // 计算顶点坐标从模型坐标系转换到裁剪面坐标系
        v2f vert(a2v v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.worldNormal = UnityObjectToWorldNormal(v.normal);
            o.worldPos = mul(unity_WorldToObject, v.vertex).xyz;
            //使用内置的TRANSFORM_TEX宏来计算经过平铺和偏移后的纹理坐标
            o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);

            return o;
        }


        // 计算每个像素点的颜色值
        fixed4 frag(v2f i) : SV_Target {

            // 法线方向，反过来相乘就是从模型到世界的变换
            fixed3 worldNormal = normalize(i.worldNormal);
        // 光照方向。
        fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
        // 环境光
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        //使用纹理去采样漫反射颜色 ，通过0.5倍的缩放和偏移将halfLambert范围映射到[0,1]之间
        //采用半兰伯特 mo'x
        fixed halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
        //使用halfLambert来构建u，v方向上的纹理坐标
        fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;
        //漫反射
        fixed3 diffuse = _LightColor0.rgb * diffuseColor;
        // 视野方向
        fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
        fixed3 halfDir = normalize(worldLightDir + viewDir);
        //高光反射
        fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(dot(worldNormal, halfDir), 0), _Gloss);

        // 最终颜色 = 漫反射 + 环境光 + 高光反射
        return fixed4(diffuse + ambient + specular, 1.0);
    }

    ENDCG
}
        }
            FallBack "Specular"
}