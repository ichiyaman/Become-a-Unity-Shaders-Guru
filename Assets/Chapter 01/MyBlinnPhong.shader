Shader "Custom/MyBlinnPhong"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float3 normalWS     : NORMAL;
            };

            float4 _BaseColor;
            float _Gloss;

            Varyings vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                output.positionCS = TransformObjectToHClip(input.positionOS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                half3 normalWS = normalize(input.normalWS);
                //half3 lightDirWS = normalize(_WorldSpaceLightPos0.xyz);

               // Get main light data
                Light mainLight = GetMainLight();
                half3 lightDirWS = normalize(mainLight.direction);
                
                half3 viewDirWS = normalize(_WorldSpaceCameraPos.xyz - input.positionCS.xyz);

                half3 diffuse = _BaseColor.rgb * max(0, dot(normalWS, lightDirWS));
                half3 specular = _BaseColor.rgb * pow(max(0, dot(reflect(-viewDirWS, normalWS), lightDirWS)), _Gloss * 128);

                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _BaseColor.rgb;
                half3 color = ambient + diffuse + specular;

                return half4(color, _BaseColor.a);
            }
            ENDHLSL
        }
    }
}