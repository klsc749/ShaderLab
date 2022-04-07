Shader "Custom/RampTexture"{
    Properties{
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        //����������������_RampTex
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
        //������Properties����Ӧ���������Ա���
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


        // ���㶥�������ģ������ϵת�����ü�������ϵ
        v2f vert(a2v v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.worldNormal = UnityObjectToWorldNormal(v.normal);
            o.worldPos = mul(unity_WorldToObject, v.vertex).xyz;
            //ʹ�����õ�TRANSFORM_TEX�������㾭��ƽ�̺�ƫ�ƺ����������
            o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);

            return o;
        }


        // ����ÿ�����ص����ɫֵ
        fixed4 frag(v2f i) : SV_Target {

            // ���߷��򣬷�������˾��Ǵ�ģ�͵�����ı任
            fixed3 worldNormal = normalize(i.worldNormal);
        // ���շ���
        fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
        // ������
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        //ʹ������ȥ������������ɫ ��ͨ��0.5�������ź�ƫ�ƽ�halfLambert��Χӳ�䵽[0,1]֮��
        //���ð������� mo'x
        fixed halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
        //ʹ��halfLambert������u��v�����ϵ���������
        fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;
        //������
        fixed3 diffuse = _LightColor0.rgb * diffuseColor;
        // ��Ұ����
        fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
        fixed3 halfDir = normalize(worldLightDir + viewDir);
        //�߹ⷴ��
        fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(dot(worldNormal, halfDir), 0), _Gloss);

        // ������ɫ = ������ + ������ + �߹ⷴ��
        return fixed4(diffuse + ambient + specular, 1.0);
    }

    ENDCG
}
        }
            FallBack "Specular"
}