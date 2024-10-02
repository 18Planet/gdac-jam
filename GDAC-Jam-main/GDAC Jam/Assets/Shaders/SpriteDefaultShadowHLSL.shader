Shader "SpriteDefaultShadowHLSL"
{
    Properties
    {
        [NoScaleOffset] _MainTex("MainTex", 2D) = "white" {}
        _DefaultXRot("DefaultXRot", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalLitSubTarget"
            "DisableBatching" = "True"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        #define _SPECULAR_SETUP 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float4 color;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 WorldSpaceTangent;
             float3 ObjectSpaceBiTangent;
             float3 WorldSpaceBiTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
             float3 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float2 interp7 : INTERP7;
             float3 interp8 : INTERP8;
             float4 interp9 : INTERP9;
             float4 interp10 : INTERP10;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz = input.positionWS;
            output.interp1.xyz = input.normalWS;
            output.interp2.xyzw = input.tangentWS;
            output.interp3.xyzw = input.texCoord0;
            output.interp4.xyzw = input.color;
            output.interp5.xyz = input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp6.xy = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp7.xy = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp8.xyz = input.sh;
            #endif
            output.interp9.xyzw = input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp10.xyzw = input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
            output.viewDirectionWS = input.interp5.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp6.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp7.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp8.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp9.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp10.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float _DefaultXRot;
        CBUFFER_END

            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Functions

            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
            {
                Rotation = radians(Rotation);

                float s = sin(Rotation);
                float c = cos(Rotation);
                float one_minus_c = 1.0 - c;

                Axis = normalize(Axis);

                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                        };

                Out = mul(rot_mat,  In);
            }

            struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
            {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpacePosition;
            };

            void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
            {
            float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
            float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
            float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
            Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
            Out = A * B;
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }

            struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
            {
            float4 VertexColor;
            half4 uv0;
            };

            void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
            {
            UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
            float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
            float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
            Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
            float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
            float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
            float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
            float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
            float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
            Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
            Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
            Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float3 Specular;
                float Smoothness;
                float Occlusion;
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                surface.BaseColor = (_SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2.xyz);
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = float3(0, 0, 0);
                surface.Specular = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                surface.Smoothness = 0;
                surface.Occlusion = 0;
                surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                surface.AlphaClipThreshold = 0.1;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition = input.positionOS;
                output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

            #endif





                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.uv0 = input.texCoord0;
                output.VertexColor = input.color;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif

            ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }

                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag

                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                #pragma multi_compile_fragment _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
                #pragma multi_compile_fragment _ _LIGHT_LAYERS
                #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                // GraphKeywords: <None>

                // Defines

                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define ATTRIBUTES_NEED_COLOR
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_COLOR
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SHADOW_COORD
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                #define _FOG_FRAGMENT 1
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _ALPHATEST_ON 1
                #define _SPECULAR_SETUP 1
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                     float4 color : COLOR;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                     float4 color;
                     float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float4 uv0;
                     float4 VertexColor;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 WorldSpaceTangent;
                     float3 ObjectSpaceBiTangent;
                     float3 WorldSpaceBiTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                     float4 interp3 : INTERP3;
                     float4 interp4 : INTERP4;
                     float3 interp5 : INTERP5;
                     float2 interp6 : INTERP6;
                     float2 interp7 : INTERP7;
                     float3 interp8 : INTERP8;
                     float4 interp9 : INTERP9;
                     float4 interp10 : INTERP10;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz = input.positionWS;
                    output.interp1.xyz = input.normalWS;
                    output.interp2.xyzw = input.tangentWS;
                    output.interp3.xyzw = input.texCoord0;
                    output.interp4.xyzw = input.color;
                    output.interp5.xyz = input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp6.xy = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.interp7.xy = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp8.xyz = input.sh;
                    #endif
                    output.interp9.xyzw = input.fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.interp10.xyzw = input.shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.color = input.interp4.xyzw;
                    output.viewDirectionWS = input.interp5.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.interp6.xy;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.interp7.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp8.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp9.xyzw;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.interp10.xyzw;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float _DefaultXRot;
                CBUFFER_END

                    // Object and Global properties
                    SAMPLER(SamplerState_Linear_Repeat);
                    TEXTURE2D(_MainTex);
                    SAMPLER(sampler_MainTex);

                    // Graph Includes
                    // GraphIncludes: <None>

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Functions

                    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                    {
                        Rotation = radians(Rotation);

                        float s = sin(Rotation);
                        float c = cos(Rotation);
                        float one_minus_c = 1.0 - c;

                        Axis = normalize(Axis);

                        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                };

                        Out = mul(rot_mat,  In);
                    }

                    struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                    {
                    float3 WorldSpaceNormal;
                    float3 WorldSpaceTangent;
                    float3 WorldSpaceBiTangent;
                    float3 WorldSpacePosition;
                    };

                    void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                    {
                    float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                    float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                    float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                    Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                    }

                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                    {
                    Out = A * B;
                    }

                    void Unity_Multiply_float_float(float A, float B, out float Out)
                    {
                    Out = A * B;
                    }

                    struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                    {
                    float4 VertexColor;
                    half4 uv0;
                    };

                    void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                    {
                    UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                    float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                    float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                    Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                    float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                    float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                    float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                    float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                    float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                    Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                    Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                    Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                        Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                        float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                        SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                        description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float3 BaseColor;
                        float3 NormalTS;
                        float3 Emission;
                        float3 Specular;
                        float Smoothness;
                        float Occlusion;
                        float Alpha;
                        float AlphaClipThreshold;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                        Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                        float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                        float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                        SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                        surface.BaseColor = (_SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2.xyz);
                        surface.NormalTS = IN.TangentSpaceNormal;
                        surface.Emission = float3(0, 0, 0);
                        surface.Specular = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                        surface.Smoothness = 0;
                        surface.Occlusion = 0;
                        surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                        surface.AlphaClipThreshold = 0.1;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs
                    #ifdef HAVE_VFX_MODIFICATION
                    #define VFX_SRP_ATTRIBUTES Attributes
                    #define VFX_SRP_VARYINGS Varyings
                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                    #endif
                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                        output.ObjectSpacePosition = input.positionOS;
                        output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                    #ifdef HAVE_VFX_MODIFICATION
                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                    #endif





                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                        output.uv0 = input.texCoord0;
                        output.VertexColor = input.color;
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                    }

                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

                    // --------------------------------------------------
                    // Visual Effect Vertex Invocations
                    #ifdef HAVE_VFX_MODIFICATION
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                    #endif

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "ShadowCaster"
                        Tags
                        {
                            "LightMode" = "ShadowCaster"
                        }

                        // Render State
                        Cull Off
                        ZTest LEqual
                        ZWrite On
                        ColorMask 0

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 4.5
                        #pragma exclude_renderers gles gles3 glcore
                        #pragma multi_compile_instancing
                        #pragma multi_compile _ DOTS_INSTANCING_ON
                        #pragma vertex vert
                        #pragma fragment frag

                        // DotsInstancingOptions: <None>
                        // HybridV1InjectedBuiltinProperties: <None>

                        // Keywords
                        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                        // GraphKeywords: <None>

                        // Defines

                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define ATTRIBUTES_NEED_COLOR
                        #define VARYINGS_NEED_NORMAL_WS
                        #define VARYINGS_NEED_TEXCOORD0
                        #define VARYINGS_NEED_COLOR
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                        #define _ALPHATEST_ON 1
                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                             float4 uv0 : TEXCOORD0;
                             float4 color : COLOR;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 normalWS;
                             float4 texCoord0;
                             float4 color;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                             float4 uv0;
                             float4 VertexColor;
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 WorldSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 WorldSpaceTangent;
                             float3 ObjectSpaceBiTangent;
                             float3 WorldSpaceBiTangent;
                             float3 ObjectSpacePosition;
                             float3 WorldSpacePosition;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 interp0 : INTERP0;
                             float4 interp1 : INTERP1;
                             float4 interp2 : INTERP2;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.interp0.xyz = input.normalWS;
                            output.interp1.xyzw = input.texCoord0;
                            output.interp2.xyzw = input.color;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.normalWS = input.interp0.xyz;
                            output.texCoord0 = input.interp1.xyzw;
                            output.color = input.interp2.xyzw;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float4 _MainTex_TexelSize;
                        float _DefaultXRot;
                        CBUFFER_END

                            // Object and Global properties
                            SAMPLER(SamplerState_Linear_Repeat);
                            TEXTURE2D(_MainTex);
                            SAMPLER(sampler_MainTex);

                            // Graph Includes
                            // GraphIncludes: <None>

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Functions

                            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                            {
                                Rotation = radians(Rotation);

                                float s = sin(Rotation);
                                float c = cos(Rotation);
                                float one_minus_c = 1.0 - c;

                                Axis = normalize(Axis);

                                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                        };

                                Out = mul(rot_mat,  In);
                            }

                            struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                            {
                            float3 WorldSpaceNormal;
                            float3 WorldSpaceTangent;
                            float3 WorldSpaceBiTangent;
                            float3 WorldSpacePosition;
                            };

                            void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                            {
                            float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                            float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                            float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                            Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                            Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                            }

                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                            {
                            Out = A * B;
                            }

                            void Unity_Multiply_float_float(float A, float B, out float Out)
                            {
                            Out = A * B;
                            }

                            struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                            {
                            float4 VertexColor;
                            half4 uv0;
                            };

                            void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                            {
                            UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                            float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                            float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                            Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                            float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                            float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                            float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                            float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                            float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                            Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                            Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                            Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                            }

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                                Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                                float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                                description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                                float Alpha;
                                float AlphaClipThreshold;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                                float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                                float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                                surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                surface.AlphaClipThreshold = 0.1;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs
                            #ifdef HAVE_VFX_MODIFICATION
                            #define VFX_SRP_ATTRIBUTES Attributes
                            #define VFX_SRP_VARYINGS Varyings
                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                            #endif
                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                output.ObjectSpacePosition = input.positionOS;
                                output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                            #ifdef HAVE_VFX_MODIFICATION
                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                            #endif







                                output.uv0 = input.texCoord0;
                                output.VertexColor = input.color;
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                            }

                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                            // --------------------------------------------------
                            // Visual Effect Vertex Invocations
                            #ifdef HAVE_VFX_MODIFICATION
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                            #endif

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "DepthNormals"
                                Tags
                                {
                                    "LightMode" = "DepthNormals"
                                }

                                // Render State
                                Cull Off
                                ZTest LEqual
                                ZWrite On

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 4.5
                                #pragma exclude_renderers gles gles3 glcore
                                #pragma multi_compile_instancing
                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                #pragma vertex vert
                                #pragma fragment frag

                                // DotsInstancingOptions: <None>
                                // HybridV1InjectedBuiltinProperties: <None>

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines

                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define ATTRIBUTES_NEED_TEXCOORD0
                                #define ATTRIBUTES_NEED_TEXCOORD1
                                #define ATTRIBUTES_NEED_COLOR
                                #define VARYINGS_NEED_NORMAL_WS
                                #define VARYINGS_NEED_TANGENT_WS
                                #define VARYINGS_NEED_TEXCOORD0
                                #define VARYINGS_NEED_COLOR
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                #define _ALPHATEST_ON 1
                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                     float4 uv0 : TEXCOORD0;
                                     float4 uv1 : TEXCOORD1;
                                     float4 color : COLOR;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 normalWS;
                                     float4 tangentWS;
                                     float4 texCoord0;
                                     float4 color;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                     float3 TangentSpaceNormal;
                                     float4 uv0;
                                     float4 VertexColor;
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 WorldSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 WorldSpaceTangent;
                                     float3 ObjectSpaceBiTangent;
                                     float3 WorldSpaceBiTangent;
                                     float3 ObjectSpacePosition;
                                     float3 WorldSpacePosition;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 interp0 : INTERP0;
                                     float4 interp1 : INTERP1;
                                     float4 interp2 : INTERP2;
                                     float4 interp3 : INTERP3;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    output.interp0.xyz = input.normalWS;
                                    output.interp1.xyzw = input.tangentWS;
                                    output.interp2.xyzw = input.texCoord0;
                                    output.interp3.xyzw = input.color;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    output.normalWS = input.interp0.xyz;
                                    output.tangentWS = input.interp1.xyzw;
                                    output.texCoord0 = input.interp2.xyzw;
                                    output.color = input.interp3.xyzw;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float4 _MainTex_TexelSize;
                                float _DefaultXRot;
                                CBUFFER_END

                                    // Object and Global properties
                                    SAMPLER(SamplerState_Linear_Repeat);
                                    TEXTURE2D(_MainTex);
                                    SAMPLER(sampler_MainTex);

                                    // Graph Includes
                                    // GraphIncludes: <None>

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                    // -- Properties used by SceneSelectionPass
                                    #ifdef SCENESELECTIONPASS
                                    int _ObjectId;
                                    int _PassValue;
                                    #endif

                                    // Graph Functions

                                    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                    {
                                        Rotation = radians(Rotation);

                                        float s = sin(Rotation);
                                        float c = cos(Rotation);
                                        float one_minus_c = 1.0 - c;

                                        Axis = normalize(Axis);

                                        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                };

                                        Out = mul(rot_mat,  In);
                                    }

                                    struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                                    {
                                    float3 WorldSpaceNormal;
                                    float3 WorldSpaceTangent;
                                    float3 WorldSpaceBiTangent;
                                    float3 WorldSpacePosition;
                                    };

                                    void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                                    {
                                    float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                                    float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                                    float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                    Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                                    Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                    }

                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                    {
                                    Out = A * B;
                                    }

                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                    {
                                    Out = A * B;
                                    }

                                    struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                                    {
                                    float4 VertexColor;
                                    half4 uv0;
                                    };

                                    void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                                    {
                                    UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                                    float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                                    float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                    Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                                    float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                                    float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                                    float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                                    float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                                    float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                    Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                                    Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                    Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                    }

                                    // Custom interpolators pre vertex
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                    // Graph Vertex
                                    struct VertexDescription
                                    {
                                        float3 Position;
                                        float3 Normal;
                                        float3 Tangent;
                                    };

                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                    {
                                        VertexDescription description = (VertexDescription)0;
                                        float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                                        Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                                        float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                        SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                                        description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Custom interpolators, pre surface
                                    #ifdef FEATURES_GRAPH_VERTEX
                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                    {
                                    return output;
                                    }
                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                    #endif

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                        float3 NormalTS;
                                        float Alpha;
                                        float AlphaClipThreshold;
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                        Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                                        float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                                        float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                        SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                                        surface.NormalTS = IN.TangentSpaceNormal;
                                        surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                        surface.AlphaClipThreshold = 0.1;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #define VFX_SRP_ATTRIBUTES Attributes
                                    #define VFX_SRP_VARYINGS Varyings
                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                    #endif
                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                        output.ObjectSpacePosition = input.positionOS;
                                        output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                                        return output;
                                    }
                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                    #ifdef HAVE_VFX_MODIFICATION
                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                    #endif





                                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                        output.uv0 = input.texCoord0;
                                        output.VertexColor = input.color;
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                    #else
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                    #endif
                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                            return output;
                                    }

                                    // --------------------------------------------------
                                    // Main

                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                    // --------------------------------------------------
                                    // Visual Effect Vertex Invocations
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                    #endif

                                    ENDHLSL
                                    }
                                    Pass
                                    {
                                        Name "Meta"
                                        Tags
                                        {
                                            "LightMode" = "Meta"
                                        }

                                        // Render State
                                        Cull Off

                                        // Debug
                                        // <None>

                                        // --------------------------------------------------
                                        // Pass

                                        HLSLPROGRAM

                                        // Pragmas
                                        #pragma target 4.5
                                        #pragma exclude_renderers gles gles3 glcore
                                        #pragma vertex vert
                                        #pragma fragment frag

                                        // DotsInstancingOptions: <None>
                                        // HybridV1InjectedBuiltinProperties: <None>

                                        // Keywords
                                        #pragma shader_feature _ EDITOR_VISUALIZATION
                                        // GraphKeywords: <None>

                                        // Defines

                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_TS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                        #define ATTRIBUTES_NEED_TEXCOORD2
                                        #define ATTRIBUTES_NEED_COLOR
                                        #define VARYINGS_NEED_TEXCOORD0
                                        #define VARYINGS_NEED_TEXCOORD1
                                        #define VARYINGS_NEED_TEXCOORD2
                                        #define VARYINGS_NEED_COLOR
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_META
                                        #define _FOG_FRAGMENT 1
                                        #define _ALPHATEST_ON 1
                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                        // custom interpolator pre-include
                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                        // Includes
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                        // --------------------------------------------------
                                        // Structs and Packing

                                        // custom interpolators pre packing
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                        struct Attributes
                                        {
                                             float3 positionOS : POSITION;
                                             float3 normalOS : NORMAL;
                                             float4 tangentOS : TANGENT;
                                             float4 uv0 : TEXCOORD0;
                                             float4 uv1 : TEXCOORD1;
                                             float4 uv2 : TEXCOORD2;
                                             float4 color : COLOR;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float4 texCoord0;
                                             float4 texCoord1;
                                             float4 texCoord2;
                                             float4 color;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };
                                        struct SurfaceDescriptionInputs
                                        {
                                             float4 uv0;
                                             float4 VertexColor;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                             float3 ObjectSpaceNormal;
                                             float3 WorldSpaceNormal;
                                             float3 ObjectSpaceTangent;
                                             float3 WorldSpaceTangent;
                                             float3 ObjectSpaceBiTangent;
                                             float3 WorldSpaceBiTangent;
                                             float3 ObjectSpacePosition;
                                             float3 WorldSpacePosition;
                                        };
                                        struct PackedVaryings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float4 interp0 : INTERP0;
                                             float4 interp1 : INTERP1;
                                             float4 interp2 : INTERP2;
                                             float4 interp3 : INTERP3;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };

                                        PackedVaryings PackVaryings(Varyings input)
                                        {
                                            PackedVaryings output;
                                            ZERO_INITIALIZE(PackedVaryings, output);
                                            output.positionCS = input.positionCS;
                                            output.interp0.xyzw = input.texCoord0;
                                            output.interp1.xyzw = input.texCoord1;
                                            output.interp2.xyzw = input.texCoord2;
                                            output.interp3.xyzw = input.color;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }

                                        Varyings UnpackVaryings(PackedVaryings input)
                                        {
                                            Varyings output;
                                            output.positionCS = input.positionCS;
                                            output.texCoord0 = input.interp0.xyzw;
                                            output.texCoord1 = input.interp1.xyzw;
                                            output.texCoord2 = input.interp2.xyzw;
                                            output.color = input.interp3.xyzw;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }


                                        // --------------------------------------------------
                                        // Graph

                                        // Graph Properties
                                        CBUFFER_START(UnityPerMaterial)
                                        float4 _MainTex_TexelSize;
                                        float _DefaultXRot;
                                        CBUFFER_END

                                            // Object and Global properties
                                            SAMPLER(SamplerState_Linear_Repeat);
                                            TEXTURE2D(_MainTex);
                                            SAMPLER(sampler_MainTex);

                                            // Graph Includes
                                            // GraphIncludes: <None>

                                            // -- Property used by ScenePickingPass
                                            #ifdef SCENEPICKINGPASS
                                            float4 _SelectionID;
                                            #endif

                                            // -- Properties used by SceneSelectionPass
                                            #ifdef SCENESELECTIONPASS
                                            int _ObjectId;
                                            int _PassValue;
                                            #endif

                                            // Graph Functions

                                            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                            {
                                                Rotation = radians(Rotation);

                                                float s = sin(Rotation);
                                                float c = cos(Rotation);
                                                float one_minus_c = 1.0 - c;

                                                Axis = normalize(Axis);

                                                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                        };

                                                Out = mul(rot_mat,  In);
                                            }

                                            struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                                            {
                                            float3 WorldSpaceNormal;
                                            float3 WorldSpaceTangent;
                                            float3 WorldSpaceBiTangent;
                                            float3 WorldSpacePosition;
                                            };

                                            void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                                            {
                                            float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                                            float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                                            float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                            Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                                            Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                            }

                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                            {
                                            Out = A * B;
                                            }

                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                            {
                                            Out = A * B;
                                            }

                                            struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                                            {
                                            float4 VertexColor;
                                            half4 uv0;
                                            };

                                            void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                                            {
                                            UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                                            float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                                            float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                            Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                                            float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                                            float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                                            float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                                            float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                                            float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                            Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                                            Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                            Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                            }

                                            // Custom interpolators pre vertex
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                            // Graph Vertex
                                            struct VertexDescription
                                            {
                                                float3 Position;
                                                float3 Normal;
                                                float3 Tangent;
                                            };

                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                            {
                                                VertexDescription description = (VertexDescription)0;
                                                float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                                                Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                                                float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                                                description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                description.Normal = IN.ObjectSpaceNormal;
                                                description.Tangent = IN.ObjectSpaceTangent;
                                                return description;
                                            }

                                            // Custom interpolators, pre surface
                                            #ifdef FEATURES_GRAPH_VERTEX
                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                            {
                                            return output;
                                            }
                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                            #endif

                                            // Graph Pixel
                                            struct SurfaceDescription
                                            {
                                                float3 BaseColor;
                                                float3 Emission;
                                                float Alpha;
                                                float AlphaClipThreshold;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                                                float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                                                float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                                                surface.BaseColor = (_SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2.xyz);
                                                surface.Emission = float3(0, 0, 0);
                                                surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                surface.AlphaClipThreshold = 0.1;
                                                return surface;
                                            }

                                            // --------------------------------------------------
                                            // Build Graph Inputs
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #define VFX_SRP_ATTRIBUTES Attributes
                                            #define VFX_SRP_VARYINGS Varyings
                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                            #endif
                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                            {
                                                VertexDescriptionInputs output;
                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                output.ObjectSpaceNormal = input.normalOS;
                                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                output.ObjectSpacePosition = input.positionOS;
                                                output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                                                return output;
                                            }
                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                            #ifdef HAVE_VFX_MODIFICATION
                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                            #endif







                                                output.uv0 = input.texCoord0;
                                                output.VertexColor = input.color;
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                            #else
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                            #endif
                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                    return output;
                                            }

                                            // --------------------------------------------------
                                            // Main

                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                            // --------------------------------------------------
                                            // Visual Effect Vertex Invocations
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                            #endif

                                            ENDHLSL
                                            }
                                            Pass
                                            {
                                                Name "SceneSelectionPass"
                                                Tags
                                                {
                                                    "LightMode" = "SceneSelectionPass"
                                                }

                                                // Render State
                                                Cull Off

                                                // Debug
                                                // <None>

                                                // --------------------------------------------------
                                                // Pass

                                                HLSLPROGRAM

                                                // Pragmas
                                                #pragma target 4.5
                                                #pragma exclude_renderers gles gles3 glcore
                                                #pragma vertex vert
                                                #pragma fragment frag

                                                // DotsInstancingOptions: <None>
                                                // HybridV1InjectedBuiltinProperties: <None>

                                                // Keywords
                                                // PassKeywords: <None>
                                                // GraphKeywords: <None>

                                                // Defines

                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_TS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                #define ATTRIBUTES_NEED_COLOR
                                                #define VARYINGS_NEED_TEXCOORD0
                                                #define VARYINGS_NEED_COLOR
                                                #define FEATURES_GRAPH_VERTEX
                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                #define SCENESELECTIONPASS 1
                                                #define ALPHA_CLIP_THRESHOLD 1
                                                #define _ALPHATEST_ON 1
                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                // custom interpolator pre-include
                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                // Includes
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                // --------------------------------------------------
                                                // Structs and Packing

                                                // custom interpolators pre packing
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                struct Attributes
                                                {
                                                     float3 positionOS : POSITION;
                                                     float3 normalOS : NORMAL;
                                                     float4 tangentOS : TANGENT;
                                                     float4 uv0 : TEXCOORD0;
                                                     float4 color : COLOR;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float4 texCoord0;
                                                     float4 color;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };
                                                struct SurfaceDescriptionInputs
                                                {
                                                     float4 uv0;
                                                     float4 VertexColor;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                     float3 ObjectSpaceNormal;
                                                     float3 WorldSpaceNormal;
                                                     float3 ObjectSpaceTangent;
                                                     float3 WorldSpaceTangent;
                                                     float3 ObjectSpaceBiTangent;
                                                     float3 WorldSpaceBiTangent;
                                                     float3 ObjectSpacePosition;
                                                     float3 WorldSpacePosition;
                                                };
                                                struct PackedVaryings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float4 interp0 : INTERP0;
                                                     float4 interp1 : INTERP1;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };

                                                PackedVaryings PackVaryings(Varyings input)
                                                {
                                                    PackedVaryings output;
                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                    output.positionCS = input.positionCS;
                                                    output.interp0.xyzw = input.texCoord0;
                                                    output.interp1.xyzw = input.color;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }

                                                Varyings UnpackVaryings(PackedVaryings input)
                                                {
                                                    Varyings output;
                                                    output.positionCS = input.positionCS;
                                                    output.texCoord0 = input.interp0.xyzw;
                                                    output.color = input.interp1.xyzw;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }


                                                // --------------------------------------------------
                                                // Graph

                                                // Graph Properties
                                                CBUFFER_START(UnityPerMaterial)
                                                float4 _MainTex_TexelSize;
                                                float _DefaultXRot;
                                                CBUFFER_END

                                                    // Object and Global properties
                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                    TEXTURE2D(_MainTex);
                                                    SAMPLER(sampler_MainTex);

                                                    // Graph Includes
                                                    // GraphIncludes: <None>

                                                    // -- Property used by ScenePickingPass
                                                    #ifdef SCENEPICKINGPASS
                                                    float4 _SelectionID;
                                                    #endif

                                                    // -- Properties used by SceneSelectionPass
                                                    #ifdef SCENESELECTIONPASS
                                                    int _ObjectId;
                                                    int _PassValue;
                                                    #endif

                                                    // Graph Functions

                                                    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                    {
                                                        Rotation = radians(Rotation);

                                                        float s = sin(Rotation);
                                                        float c = cos(Rotation);
                                                        float one_minus_c = 1.0 - c;

                                                        Axis = normalize(Axis);

                                                        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                };

                                                        Out = mul(rot_mat,  In);
                                                    }

                                                    struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                                                    {
                                                    float3 WorldSpaceNormal;
                                                    float3 WorldSpaceTangent;
                                                    float3 WorldSpaceBiTangent;
                                                    float3 WorldSpacePosition;
                                                    };

                                                    void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                                                    {
                                                    float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                                                    float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                                                    float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                    Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                                                    Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                    }

                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                    Out = A * B;
                                                    }

                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                    {
                                                    Out = A * B;
                                                    }

                                                    struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                                                    {
                                                    float4 VertexColor;
                                                    half4 uv0;
                                                    };

                                                    void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                                                    {
                                                    UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                                                    float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                                                    float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                    Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                                                    float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                                                    float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                                                    float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                                                    float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                                                    float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                    Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                                                    Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                    Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                    }

                                                    // Custom interpolators pre vertex
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                    // Graph Vertex
                                                    struct VertexDescription
                                                    {
                                                        float3 Position;
                                                        float3 Normal;
                                                        float3 Tangent;
                                                    };

                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                    {
                                                        VertexDescription description = (VertexDescription)0;
                                                        float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                                                        Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                                                        float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                        SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                                                        description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                        description.Normal = IN.ObjectSpaceNormal;
                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                        return description;
                                                    }

                                                    // Custom interpolators, pre surface
                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                    {
                                                    return output;
                                                    }
                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                    #endif

                                                    // Graph Pixel
                                                    struct SurfaceDescription
                                                    {
                                                        float Alpha;
                                                        float AlphaClipThreshold;
                                                    };

                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                    {
                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                        UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                        Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                                                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                                                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                                                        float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                                                        float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                        SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                                                        surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                        surface.AlphaClipThreshold = 0.1;
                                                        return surface;
                                                    }

                                                    // --------------------------------------------------
                                                    // Build Graph Inputs
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                    #define VFX_SRP_VARYINGS Varyings
                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                    #endif
                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                    {
                                                        VertexDescriptionInputs output;
                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                        output.ObjectSpaceNormal = input.normalOS;
                                                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                        output.ObjectSpacePosition = input.positionOS;
                                                        output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                                                        return output;
                                                    }
                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                    {
                                                        SurfaceDescriptionInputs output;
                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                    #ifdef HAVE_VFX_MODIFICATION
                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                    #endif







                                                        output.uv0 = input.texCoord0;
                                                        output.VertexColor = input.color;
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                    #else
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                    #endif
                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                            return output;
                                                    }

                                                    // --------------------------------------------------
                                                    // Main

                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                    // --------------------------------------------------
                                                    // Visual Effect Vertex Invocations
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                    #endif

                                                    ENDHLSL
                                                    }
                                                    Pass
                                                    {
                                                        Name "ScenePickingPass"
                                                        Tags
                                                        {
                                                            "LightMode" = "Picking"
                                                        }

                                                        // Render State
                                                        Cull Off

                                                        // Debug
                                                        // <None>

                                                        // --------------------------------------------------
                                                        // Pass

                                                        HLSLPROGRAM

                                                        // Pragmas
                                                        #pragma target 4.5
                                                        #pragma exclude_renderers gles gles3 glcore
                                                        #pragma vertex vert
                                                        #pragma fragment frag

                                                        // DotsInstancingOptions: <None>
                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                        // Keywords
                                                        // PassKeywords: <None>
                                                        // GraphKeywords: <None>

                                                        // Defines

                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_TS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                        #define ATTRIBUTES_NEED_COLOR
                                                        #define VARYINGS_NEED_TEXCOORD0
                                                        #define VARYINGS_NEED_COLOR
                                                        #define FEATURES_GRAPH_VERTEX
                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                        #define SCENEPICKINGPASS 1
                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                        #define _ALPHATEST_ON 1
                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                        // custom interpolator pre-include
                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                        // Includes
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                        // --------------------------------------------------
                                                        // Structs and Packing

                                                        // custom interpolators pre packing
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                        struct Attributes
                                                        {
                                                             float3 positionOS : POSITION;
                                                             float3 normalOS : NORMAL;
                                                             float4 tangentOS : TANGENT;
                                                             float4 uv0 : TEXCOORD0;
                                                             float4 color : COLOR;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float4 texCoord0;
                                                             float4 color;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct SurfaceDescriptionInputs
                                                        {
                                                             float4 uv0;
                                                             float4 VertexColor;
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                             float3 ObjectSpaceNormal;
                                                             float3 WorldSpaceNormal;
                                                             float3 ObjectSpaceTangent;
                                                             float3 WorldSpaceTangent;
                                                             float3 ObjectSpaceBiTangent;
                                                             float3 WorldSpaceBiTangent;
                                                             float3 ObjectSpacePosition;
                                                             float3 WorldSpacePosition;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float4 interp0 : INTERP0;
                                                             float4 interp1 : INTERP1;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };

                                                        PackedVaryings PackVaryings(Varyings input)
                                                        {
                                                            PackedVaryings output;
                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                            output.positionCS = input.positionCS;
                                                            output.interp0.xyzw = input.texCoord0;
                                                            output.interp1.xyzw = input.color;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }

                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                        {
                                                            Varyings output;
                                                            output.positionCS = input.positionCS;
                                                            output.texCoord0 = input.interp0.xyzw;
                                                            output.color = input.interp1.xyzw;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }


                                                        // --------------------------------------------------
                                                        // Graph

                                                        // Graph Properties
                                                        CBUFFER_START(UnityPerMaterial)
                                                        float4 _MainTex_TexelSize;
                                                        float _DefaultXRot;
                                                        CBUFFER_END

                                                            // Object and Global properties
                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                            TEXTURE2D(_MainTex);
                                                            SAMPLER(sampler_MainTex);

                                                            // Graph Includes
                                                            // GraphIncludes: <None>

                                                            // -- Property used by ScenePickingPass
                                                            #ifdef SCENEPICKINGPASS
                                                            float4 _SelectionID;
                                                            #endif

                                                            // -- Properties used by SceneSelectionPass
                                                            #ifdef SCENESELECTIONPASS
                                                            int _ObjectId;
                                                            int _PassValue;
                                                            #endif

                                                            // Graph Functions

                                                            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                            {
                                                                Rotation = radians(Rotation);

                                                                float s = sin(Rotation);
                                                                float c = cos(Rotation);
                                                                float one_minus_c = 1.0 - c;

                                                                Axis = normalize(Axis);

                                                                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                        };

                                                                Out = mul(rot_mat,  In);
                                                            }

                                                            struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                                                            {
                                                            float3 WorldSpaceNormal;
                                                            float3 WorldSpaceTangent;
                                                            float3 WorldSpaceBiTangent;
                                                            float3 WorldSpacePosition;
                                                            };

                                                            void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                                                            {
                                                            float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                                                            float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                                                            float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                            Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                                                            Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                            }

                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                            {
                                                            Out = A * B;
                                                            }

                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                            {
                                                            Out = A * B;
                                                            }

                                                            struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                                                            {
                                                            float4 VertexColor;
                                                            half4 uv0;
                                                            };

                                                            void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                                                            {
                                                            UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                                                            float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                                                            float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                            Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                                                            float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                                                            float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                                                            float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                                                            float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                                                            float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                            Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                                                            Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                            Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                            }

                                                            // Custom interpolators pre vertex
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                            // Graph Vertex
                                                            struct VertexDescription
                                                            {
                                                                float3 Position;
                                                                float3 Normal;
                                                                float3 Tangent;
                                                            };

                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                            {
                                                                VertexDescription description = (VertexDescription)0;
                                                                float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                                                                Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                                                                float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                                                                description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                return description;
                                                            }

                                                            // Custom interpolators, pre surface
                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                            {
                                                            return output;
                                                            }
                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                            #endif

                                                            // Graph Pixel
                                                            struct SurfaceDescription
                                                            {
                                                                float Alpha;
                                                                float AlphaClipThreshold;
                                                            };

                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                            {
                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                                                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                                                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                                                                float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                                                                float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                                                                surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                surface.AlphaClipThreshold = 0.1;
                                                                return surface;
                                                            }

                                                            // --------------------------------------------------
                                                            // Build Graph Inputs
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                            #define VFX_SRP_VARYINGS Varyings
                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                            #endif
                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                            {
                                                                VertexDescriptionInputs output;
                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                output.ObjectSpacePosition = input.positionOS;
                                                                output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                                                                return output;
                                                            }
                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                            {
                                                                SurfaceDescriptionInputs output;
                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                            #endif







                                                                output.uv0 = input.texCoord0;
                                                                output.VertexColor = input.color;
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                            #else
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                            #endif
                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                    return output;
                                                            }

                                                            // --------------------------------------------------
                                                            // Main

                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                            // --------------------------------------------------
                                                            // Visual Effect Vertex Invocations
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                            #endif

                                                            ENDHLSL
                                                            }
                                                            Pass
                                                            {
                                                                // Name: <None>
                                                                Tags
                                                                {
                                                                    "LightMode" = "Universal2D"
                                                                }

                                                                // Render State
                                                                Cull Off
                                                                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                ZTest LEqual
                                                                ZWrite Off

                                                                // Debug
                                                                // <None>

                                                                // --------------------------------------------------
                                                                // Pass

                                                                HLSLPROGRAM

                                                                // Pragmas
                                                                #pragma target 4.5
                                                                #pragma exclude_renderers gles gles3 glcore
                                                                #pragma vertex vert
                                                                #pragma fragment frag

                                                                // DotsInstancingOptions: <None>
                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                // Keywords
                                                                // PassKeywords: <None>
                                                                // GraphKeywords: <None>

                                                                // Defines

                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_TS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                #define ATTRIBUTES_NEED_COLOR
                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                #define VARYINGS_NEED_COLOR
                                                                #define FEATURES_GRAPH_VERTEX
                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                #define SHADERPASS SHADERPASS_2D
                                                                #define _ALPHATEST_ON 1
                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                // custom interpolator pre-include
                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                // Includes
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                // --------------------------------------------------
                                                                // Structs and Packing

                                                                // custom interpolators pre packing
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                struct Attributes
                                                                {
                                                                     float3 positionOS : POSITION;
                                                                     float3 normalOS : NORMAL;
                                                                     float4 tangentOS : TANGENT;
                                                                     float4 uv0 : TEXCOORD0;
                                                                     float4 color : COLOR;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct Varyings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float4 texCoord0;
                                                                     float4 color;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct SurfaceDescriptionInputs
                                                                {
                                                                     float4 uv0;
                                                                     float4 VertexColor;
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                     float3 ObjectSpaceNormal;
                                                                     float3 WorldSpaceNormal;
                                                                     float3 ObjectSpaceTangent;
                                                                     float3 WorldSpaceTangent;
                                                                     float3 ObjectSpaceBiTangent;
                                                                     float3 WorldSpaceBiTangent;
                                                                     float3 ObjectSpacePosition;
                                                                     float3 WorldSpacePosition;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float4 interp0 : INTERP0;
                                                                     float4 interp1 : INTERP1;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };

                                                                PackedVaryings PackVaryings(Varyings input)
                                                                {
                                                                    PackedVaryings output;
                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                    output.positionCS = input.positionCS;
                                                                    output.interp0.xyzw = input.texCoord0;
                                                                    output.interp1.xyzw = input.color;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }

                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                {
                                                                    Varyings output;
                                                                    output.positionCS = input.positionCS;
                                                                    output.texCoord0 = input.interp0.xyzw;
                                                                    output.color = input.interp1.xyzw;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }


                                                                // --------------------------------------------------
                                                                // Graph

                                                                // Graph Properties
                                                                CBUFFER_START(UnityPerMaterial)
                                                                float4 _MainTex_TexelSize;
                                                                float _DefaultXRot;
                                                                CBUFFER_END

                                                                    // Object and Global properties
                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                    TEXTURE2D(_MainTex);
                                                                    SAMPLER(sampler_MainTex);

                                                                    // Graph Includes
                                                                    // GraphIncludes: <None>

                                                                    // -- Property used by ScenePickingPass
                                                                    #ifdef SCENEPICKINGPASS
                                                                    float4 _SelectionID;
                                                                    #endif

                                                                    // -- Properties used by SceneSelectionPass
                                                                    #ifdef SCENESELECTIONPASS
                                                                    int _ObjectId;
                                                                    int _PassValue;
                                                                    #endif

                                                                    // Graph Functions

                                                                    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                                    {
                                                                        Rotation = radians(Rotation);

                                                                        float s = sin(Rotation);
                                                                        float c = cos(Rotation);
                                                                        float one_minus_c = 1.0 - c;

                                                                        Axis = normalize(Axis);

                                                                        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                                };

                                                                        Out = mul(rot_mat,  In);
                                                                    }

                                                                    struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                                                                    {
                                                                    float3 WorldSpaceNormal;
                                                                    float3 WorldSpaceTangent;
                                                                    float3 WorldSpaceBiTangent;
                                                                    float3 WorldSpacePosition;
                                                                    };

                                                                    void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                                                                    {
                                                                    float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                                                                    float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                                                                    float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                    Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                                                                    Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                    }

                                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                    {
                                                                    Out = A * B;
                                                                    }

                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                    {
                                                                    Out = A * B;
                                                                    }

                                                                    struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                                                                    {
                                                                    float4 VertexColor;
                                                                    half4 uv0;
                                                                    };

                                                                    void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                                                                    {
                                                                    UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                                                                    float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                                                                    float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                    Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                                                                    float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                                                                    float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                                                                    float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                                                                    float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                                                                    float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                    Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                                                                    Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                    Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                    }

                                                                    // Custom interpolators pre vertex
                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                    // Graph Vertex
                                                                    struct VertexDescription
                                                                    {
                                                                        float3 Position;
                                                                        float3 Normal;
                                                                        float3 Tangent;
                                                                    };

                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                    {
                                                                        VertexDescription description = (VertexDescription)0;
                                                                        float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                                                                        Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                                                                        float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                        SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                                                                        description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                        return description;
                                                                    }

                                                                    // Custom interpolators, pre surface
                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                    {
                                                                    return output;
                                                                    }
                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                    #endif

                                                                    // Graph Pixel
                                                                    struct SurfaceDescription
                                                                    {
                                                                        float3 BaseColor;
                                                                        float Alpha;
                                                                        float AlphaClipThreshold;
                                                                    };

                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                    {
                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                        UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                        Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                                                                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                                                                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                                                                        float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                                                                        float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                        SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                                                                        surface.BaseColor = (_SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2.xyz);
                                                                        surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                        surface.AlphaClipThreshold = 0.1;
                                                                        return surface;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Build Graph Inputs
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                    #endif
                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                    {
                                                                        VertexDescriptionInputs output;
                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                        output.ObjectSpacePosition = input.positionOS;
                                                                        output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                                                                        return output;
                                                                    }
                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                    {
                                                                        SurfaceDescriptionInputs output;
                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                    #endif







                                                                        output.uv0 = input.texCoord0;
                                                                        output.VertexColor = input.color;
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                    #else
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                    #endif
                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                            return output;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Main

                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                    // --------------------------------------------------
                                                                    // Visual Effect Vertex Invocations
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                    #endif

                                                                    ENDHLSL
                                                                    }
    }
        SubShader
                                                                    {
                                                                        Tags
                                                                        {
                                                                            "RenderPipeline" = "UniversalPipeline"
                                                                            "RenderType" = "Transparent"
                                                                            "UniversalMaterialType" = "Lit"
                                                                            "Queue" = "Transparent"
                                                                            "ShaderGraphShader" = "true"
                                                                            "ShaderGraphTargetId" = "UniversalLitSubTarget"
                                                                        }
                                                                        Pass
                                                                        {
                                                                            Name "Universal Forward"
                                                                            Tags
                                                                            {
                                                                                "LightMode" = "UniversalForward"
                                                                            }

                                                                        // Render State
                                                                        Cull Off
                                                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                        ZTest LEqual
                                                                        ZWrite Off

                                                                        // Debug
                                                                        // <None>

                                                                        // --------------------------------------------------
                                                                        // Pass

                                                                        HLSLPROGRAM

                                                                        // Pragmas
                                                                        #pragma target 2.0
                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                        #pragma multi_compile_instancing
                                                                        #pragma multi_compile_fog
                                                                        #pragma instancing_options renderinglayer
                                                                        #pragma vertex vert
                                                                        #pragma fragment frag

                                                                        // DotsInstancingOptions: <None>
                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                        // Keywords
                                                                        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
                                                                        #pragma multi_compile _ LIGHTMAP_ON
                                                                        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                                                                        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                                                                        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                                                                        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                                                                        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
                                                                        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                                                                        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                                                                        #pragma multi_compile_fragment _ _SHADOWS_SOFT
                                                                        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                                                                        #pragma multi_compile _ SHADOWS_SHADOWMASK
                                                                        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                                                                        #pragma multi_compile_fragment _ _LIGHT_LAYERS
                                                                        #pragma multi_compile_fragment _ DEBUG_DISPLAY
                                                                        #pragma multi_compile_fragment _ _LIGHT_COOKIES
                                                                        #pragma multi_compile _ _CLUSTERED_RENDERING
                                                                        // GraphKeywords: <None>

                                                                        // Defines

                                                                        #define _NORMALMAP 1
                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                        #define ATTRIBUTES_NEED_TEXCOORD2
                                                                        #define ATTRIBUTES_NEED_COLOR
                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                        #define VARYINGS_NEED_COLOR
                                                                        #define VARYINGS_NEED_VIEWDIRECTION_WS
                                                                        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                        #define VARYINGS_NEED_SHADOW_COORD
                                                                        #define FEATURES_GRAPH_VERTEX
                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                        #define SHADERPASS SHADERPASS_FORWARD
                                                                        #define _FOG_FRAGMENT 1
                                                                        #define _SURFACE_TYPE_TRANSPARENT 1
                                                                        #define _ALPHATEST_ON 1
                                                                        #define _SPECULAR_SETUP 1
                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                        // custom interpolator pre-include
                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                        // Includes
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                        // --------------------------------------------------
                                                                        // Structs and Packing

                                                                        // custom interpolators pre packing
                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                        struct Attributes
                                                                        {
                                                                             float3 positionOS : POSITION;
                                                                             float3 normalOS : NORMAL;
                                                                             float4 tangentOS : TANGENT;
                                                                             float4 uv0 : TEXCOORD0;
                                                                             float4 uv1 : TEXCOORD1;
                                                                             float4 uv2 : TEXCOORD2;
                                                                             float4 color : COLOR;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct Varyings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 positionWS;
                                                                             float3 normalWS;
                                                                             float4 tangentWS;
                                                                             float4 texCoord0;
                                                                             float4 color;
                                                                             float3 viewDirectionWS;
                                                                            #if defined(LIGHTMAP_ON)
                                                                             float2 staticLightmapUV;
                                                                            #endif
                                                                            #if defined(DYNAMICLIGHTMAP_ON)
                                                                             float2 dynamicLightmapUV;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                             float3 sh;
                                                                            #endif
                                                                             float4 fogFactorAndVertexLight;
                                                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                             float4 shadowCoord;
                                                                            #endif
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct SurfaceDescriptionInputs
                                                                        {
                                                                             float3 TangentSpaceNormal;
                                                                             float4 uv0;
                                                                             float4 VertexColor;
                                                                        };
                                                                        struct VertexDescriptionInputs
                                                                        {
                                                                             float3 ObjectSpaceNormal;
                                                                             float3 WorldSpaceNormal;
                                                                             float3 ObjectSpaceTangent;
                                                                             float3 WorldSpaceTangent;
                                                                             float3 ObjectSpaceBiTangent;
                                                                             float3 WorldSpaceBiTangent;
                                                                             float3 ObjectSpacePosition;
                                                                             float3 WorldSpacePosition;
                                                                        };
                                                                        struct PackedVaryings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 interp0 : INTERP0;
                                                                             float3 interp1 : INTERP1;
                                                                             float4 interp2 : INTERP2;
                                                                             float4 interp3 : INTERP3;
                                                                             float4 interp4 : INTERP4;
                                                                             float3 interp5 : INTERP5;
                                                                             float2 interp6 : INTERP6;
                                                                             float2 interp7 : INTERP7;
                                                                             float3 interp8 : INTERP8;
                                                                             float4 interp9 : INTERP9;
                                                                             float4 interp10 : INTERP10;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };

                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                        {
                                                                            PackedVaryings output;
                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                            output.positionCS = input.positionCS;
                                                                            output.interp0.xyz = input.positionWS;
                                                                            output.interp1.xyz = input.normalWS;
                                                                            output.interp2.xyzw = input.tangentWS;
                                                                            output.interp3.xyzw = input.texCoord0;
                                                                            output.interp4.xyzw = input.color;
                                                                            output.interp5.xyz = input.viewDirectionWS;
                                                                            #if defined(LIGHTMAP_ON)
                                                                            output.interp6.xy = input.staticLightmapUV;
                                                                            #endif
                                                                            #if defined(DYNAMICLIGHTMAP_ON)
                                                                            output.interp7.xy = input.dynamicLightmapUV;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                            output.interp8.xyz = input.sh;
                                                                            #endif
                                                                            output.interp9.xyzw = input.fogFactorAndVertexLight;
                                                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                            output.interp10.xyzw = input.shadowCoord;
                                                                            #endif
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }

                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                        {
                                                                            Varyings output;
                                                                            output.positionCS = input.positionCS;
                                                                            output.positionWS = input.interp0.xyz;
                                                                            output.normalWS = input.interp1.xyz;
                                                                            output.tangentWS = input.interp2.xyzw;
                                                                            output.texCoord0 = input.interp3.xyzw;
                                                                            output.color = input.interp4.xyzw;
                                                                            output.viewDirectionWS = input.interp5.xyz;
                                                                            #if defined(LIGHTMAP_ON)
                                                                            output.staticLightmapUV = input.interp6.xy;
                                                                            #endif
                                                                            #if defined(DYNAMICLIGHTMAP_ON)
                                                                            output.dynamicLightmapUV = input.interp7.xy;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                            output.sh = input.interp8.xyz;
                                                                            #endif
                                                                            output.fogFactorAndVertexLight = input.interp9.xyzw;
                                                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                            output.shadowCoord = input.interp10.xyzw;
                                                                            #endif
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }


                                                                        // --------------------------------------------------
                                                                        // Graph

                                                                        // Graph Properties
                                                                        CBUFFER_START(UnityPerMaterial)
                                                                        float4 _MainTex_TexelSize;
                                                                        float _DefaultXRot;
                                                                        CBUFFER_END

                                                                            // Object and Global properties
                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                            TEXTURE2D(_MainTex);
                                                                            SAMPLER(sampler_MainTex);

                                                                            // Graph Includes
                                                                            // GraphIncludes: <None>

                                                                            // -- Property used by ScenePickingPass
                                                                            #ifdef SCENEPICKINGPASS
                                                                            float4 _SelectionID;
                                                                            #endif

                                                                            // -- Properties used by SceneSelectionPass
                                                                            #ifdef SCENESELECTIONPASS
                                                                            int _ObjectId;
                                                                            int _PassValue;
                                                                            #endif

                                                                            // Graph Functions

                                                                            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                                            {
                                                                                Rotation = radians(Rotation);

                                                                                float s = sin(Rotation);
                                                                                float c = cos(Rotation);
                                                                                float one_minus_c = 1.0 - c;

                                                                                Axis = normalize(Axis);

                                                                                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                                        };

                                                                                Out = mul(rot_mat,  In);
                                                                            }

                                                                            struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                                                                            {
                                                                            float3 WorldSpaceNormal;
                                                                            float3 WorldSpaceTangent;
                                                                            float3 WorldSpaceBiTangent;
                                                                            float3 WorldSpacePosition;
                                                                            };

                                                                            void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                                                                            {
                                                                            float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                                                                            float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                                                                            float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                            Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                                                                            Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                            }

                                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                            Out = A * B;
                                                                            }

                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                            {
                                                                            Out = A * B;
                                                                            }

                                                                            struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                                                                            {
                                                                            float4 VertexColor;
                                                                            half4 uv0;
                                                                            };

                                                                            void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                                                                            {
                                                                            UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                                                                            float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                                                                            float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                            Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                                                                            float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                                                                            float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                                                                            float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                                                                            float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                                                                            float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                            Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                                                                            Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                            Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                            }

                                                                            // Custom interpolators pre vertex
                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                            // Graph Vertex
                                                                            struct VertexDescription
                                                                            {
                                                                                float3 Position;
                                                                                float3 Normal;
                                                                                float3 Tangent;
                                                                            };

                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                            {
                                                                                VertexDescription description = (VertexDescription)0;
                                                                                float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                                                                                Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                                                                                float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                                                                                description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                return description;
                                                                            }

                                                                            // Custom interpolators, pre surface
                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                            {
                                                                            return output;
                                                                            }
                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                            #endif

                                                                            // Graph Pixel
                                                                            struct SurfaceDescription
                                                                            {
                                                                                float3 BaseColor;
                                                                                float3 NormalTS;
                                                                                float3 Emission;
                                                                                float3 Specular;
                                                                                float Smoothness;
                                                                                float Occlusion;
                                                                                float Alpha;
                                                                                float AlphaClipThreshold;
                                                                            };

                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                            {
                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                                                                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                                                                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                                                                                float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                                                                                float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                                                                                surface.BaseColor = (_SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2.xyz);
                                                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                                                surface.Emission = float3(0, 0, 0);
                                                                                surface.Specular = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                                                                                surface.Smoothness = 0;
                                                                                surface.Occlusion = 0;
                                                                                surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                surface.AlphaClipThreshold = 0.1;
                                                                                return surface;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Build Graph Inputs
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                            #endif
                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                            {
                                                                                VertexDescriptionInputs output;
                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                                output.ObjectSpacePosition = input.positionOS;
                                                                                output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                                                                                return output;
                                                                            }
                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                            {
                                                                                SurfaceDescriptionInputs output;
                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                            #endif





                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                output.uv0 = input.texCoord0;
                                                                                output.VertexColor = input.color;
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                            #else
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                            #endif
                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                    return output;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Main

                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

                                                                            // --------------------------------------------------
                                                                            // Visual Effect Vertex Invocations
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                            #endif

                                                                            ENDHLSL
                                                                            }
                                                                            Pass
                                                                            {
                                                                                Name "ShadowCaster"
                                                                                Tags
                                                                                {
                                                                                    "LightMode" = "ShadowCaster"
                                                                                }

                                                                                // Render State
                                                                                Cull Off
                                                                                ZTest LEqual
                                                                                ZWrite On
                                                                                ColorMask 0

                                                                                // Debug
                                                                                // <None>

                                                                                // --------------------------------------------------
                                                                                // Pass

                                                                                HLSLPROGRAM

                                                                                // Pragmas
                                                                                #pragma target 2.0
                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                #pragma multi_compile_instancing
                                                                                #pragma vertex vert
                                                                                #pragma fragment frag

                                                                                // DotsInstancingOptions: <None>
                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                // Keywords
                                                                                #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                                                                                // GraphKeywords: <None>

                                                                                // Defines

                                                                                #define _NORMALMAP 1
                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                #define ATTRIBUTES_NEED_COLOR
                                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                #define VARYINGS_NEED_COLOR
                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                #define SHADERPASS SHADERPASS_SHADOWCASTER
                                                                                #define _ALPHATEST_ON 1
                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                // custom interpolator pre-include
                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                // Includes
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                // --------------------------------------------------
                                                                                // Structs and Packing

                                                                                // custom interpolators pre packing
                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                struct Attributes
                                                                                {
                                                                                     float3 positionOS : POSITION;
                                                                                     float3 normalOS : NORMAL;
                                                                                     float4 tangentOS : TANGENT;
                                                                                     float4 uv0 : TEXCOORD0;
                                                                                     float4 color : COLOR;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct Varyings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 normalWS;
                                                                                     float4 texCoord0;
                                                                                     float4 color;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct SurfaceDescriptionInputs
                                                                                {
                                                                                     float4 uv0;
                                                                                     float4 VertexColor;
                                                                                };
                                                                                struct VertexDescriptionInputs
                                                                                {
                                                                                     float3 ObjectSpaceNormal;
                                                                                     float3 WorldSpaceNormal;
                                                                                     float3 ObjectSpaceTangent;
                                                                                     float3 WorldSpaceTangent;
                                                                                     float3 ObjectSpaceBiTangent;
                                                                                     float3 WorldSpaceBiTangent;
                                                                                     float3 ObjectSpacePosition;
                                                                                     float3 WorldSpacePosition;
                                                                                };
                                                                                struct PackedVaryings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 interp0 : INTERP0;
                                                                                     float4 interp1 : INTERP1;
                                                                                     float4 interp2 : INTERP2;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };

                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                {
                                                                                    PackedVaryings output;
                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.interp0.xyz = input.normalWS;
                                                                                    output.interp1.xyzw = input.texCoord0;
                                                                                    output.interp2.xyzw = input.color;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }

                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                {
                                                                                    Varyings output;
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.normalWS = input.interp0.xyz;
                                                                                    output.texCoord0 = input.interp1.xyzw;
                                                                                    output.color = input.interp2.xyzw;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }


                                                                                // --------------------------------------------------
                                                                                // Graph

                                                                                // Graph Properties
                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                float4 _MainTex_TexelSize;
                                                                                float _DefaultXRot;
                                                                                CBUFFER_END

                                                                                    // Object and Global properties
                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                    TEXTURE2D(_MainTex);
                                                                                    SAMPLER(sampler_MainTex);

                                                                                    // Graph Includes
                                                                                    // GraphIncludes: <None>

                                                                                    // -- Property used by ScenePickingPass
                                                                                    #ifdef SCENEPICKINGPASS
                                                                                    float4 _SelectionID;
                                                                                    #endif

                                                                                    // -- Properties used by SceneSelectionPass
                                                                                    #ifdef SCENESELECTIONPASS
                                                                                    int _ObjectId;
                                                                                    int _PassValue;
                                                                                    #endif

                                                                                    // Graph Functions

                                                                                    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                                                    {
                                                                                        Rotation = radians(Rotation);

                                                                                        float s = sin(Rotation);
                                                                                        float c = cos(Rotation);
                                                                                        float one_minus_c = 1.0 - c;

                                                                                        Axis = normalize(Axis);

                                                                                        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                                                };

                                                                                        Out = mul(rot_mat,  In);
                                                                                    }

                                                                                    struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                                                                                    {
                                                                                    float3 WorldSpaceNormal;
                                                                                    float3 WorldSpaceTangent;
                                                                                    float3 WorldSpaceBiTangent;
                                                                                    float3 WorldSpacePosition;
                                                                                    };

                                                                                    void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                                                                                    {
                                                                                    float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                                                                                    float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                                                                                    float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                                    Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                                                                                    Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                                    }

                                                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                    {
                                                                                    Out = A * B;
                                                                                    }

                                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                    {
                                                                                    Out = A * B;
                                                                                    }

                                                                                    struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                                                                                    {
                                                                                    float4 VertexColor;
                                                                                    half4 uv0;
                                                                                    };

                                                                                    void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                                                                                    {
                                                                                    UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                                                                                    float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                                                                                    float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                                    Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                                                                                    float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                                                                                    float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                                                                                    float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                                                                                    float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                                                                                    float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                                    Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                                                                                    Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                                    Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                                    }

                                                                                    // Custom interpolators pre vertex
                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                    // Graph Vertex
                                                                                    struct VertexDescription
                                                                                    {
                                                                                        float3 Position;
                                                                                        float3 Normal;
                                                                                        float3 Tangent;
                                                                                    };

                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                    {
                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                        float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                                                                                        Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                                                                                        float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                        SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                                                                                        description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                        return description;
                                                                                    }

                                                                                    // Custom interpolators, pre surface
                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                    {
                                                                                    return output;
                                                                                    }
                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                    #endif

                                                                                    // Graph Pixel
                                                                                    struct SurfaceDescription
                                                                                    {
                                                                                        float Alpha;
                                                                                        float AlphaClipThreshold;
                                                                                    };

                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                    {
                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                        UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                        Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                                                                                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                                                                                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                                                                                        float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                                                                                        float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                        SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                                                                                        surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                        surface.AlphaClipThreshold = 0.1;
                                                                                        return surface;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Build Graph Inputs
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                    #endif
                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                    {
                                                                                        VertexDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                                        output.ObjectSpacePosition = input.positionOS;
                                                                                        output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                                                                                        return output;
                                                                                    }
                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                    {
                                                                                        SurfaceDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                    #endif







                                                                                        output.uv0 = input.texCoord0;
                                                                                        output.VertexColor = input.color;
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                    #else
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                    #endif
                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                            return output;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Main

                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                                                                                    // --------------------------------------------------
                                                                                    // Visual Effect Vertex Invocations
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                    #endif

                                                                                    ENDHLSL
                                                                                    }
                                                                                    Pass
                                                                                    {
                                                                                        Name "DepthNormals"
                                                                                        Tags
                                                                                        {
                                                                                            "LightMode" = "DepthNormals"
                                                                                        }

                                                                                        // Render State
                                                                                        Cull Off
                                                                                        ZTest LEqual
                                                                                        ZWrite On

                                                                                        // Debug
                                                                                        // <None>

                                                                                        // --------------------------------------------------
                                                                                        // Pass

                                                                                        HLSLPROGRAM

                                                                                        // Pragmas
                                                                                        #pragma target 2.0
                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                        #pragma multi_compile_instancing
                                                                                        #pragma vertex vert
                                                                                        #pragma fragment frag

                                                                                        // DotsInstancingOptions: <None>
                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                        // Keywords
                                                                                        // PassKeywords: <None>
                                                                                        // GraphKeywords: <None>

                                                                                        // Defines

                                                                                        #define _NORMALMAP 1
                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                        #define ATTRIBUTES_NEED_COLOR
                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                        #define VARYINGS_NEED_COLOR
                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                        #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                                                                        #define _ALPHATEST_ON 1
                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                        // custom interpolator pre-include
                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                        // Includes
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                        // --------------------------------------------------
                                                                                        // Structs and Packing

                                                                                        // custom interpolators pre packing
                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                        struct Attributes
                                                                                        {
                                                                                             float3 positionOS : POSITION;
                                                                                             float3 normalOS : NORMAL;
                                                                                             float4 tangentOS : TANGENT;
                                                                                             float4 uv0 : TEXCOORD0;
                                                                                             float4 uv1 : TEXCOORD1;
                                                                                             float4 color : COLOR;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct Varyings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 normalWS;
                                                                                             float4 tangentWS;
                                                                                             float4 texCoord0;
                                                                                             float4 color;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct SurfaceDescriptionInputs
                                                                                        {
                                                                                             float3 TangentSpaceNormal;
                                                                                             float4 uv0;
                                                                                             float4 VertexColor;
                                                                                        };
                                                                                        struct VertexDescriptionInputs
                                                                                        {
                                                                                             float3 ObjectSpaceNormal;
                                                                                             float3 WorldSpaceNormal;
                                                                                             float3 ObjectSpaceTangent;
                                                                                             float3 WorldSpaceTangent;
                                                                                             float3 ObjectSpaceBiTangent;
                                                                                             float3 WorldSpaceBiTangent;
                                                                                             float3 ObjectSpacePosition;
                                                                                             float3 WorldSpacePosition;
                                                                                        };
                                                                                        struct PackedVaryings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 interp0 : INTERP0;
                                                                                             float4 interp1 : INTERP1;
                                                                                             float4 interp2 : INTERP2;
                                                                                             float4 interp3 : INTERP3;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };

                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                        {
                                                                                            PackedVaryings output;
                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.interp0.xyz = input.normalWS;
                                                                                            output.interp1.xyzw = input.tangentWS;
                                                                                            output.interp2.xyzw = input.texCoord0;
                                                                                            output.interp3.xyzw = input.color;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }

                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                        {
                                                                                            Varyings output;
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.normalWS = input.interp0.xyz;
                                                                                            output.tangentWS = input.interp1.xyzw;
                                                                                            output.texCoord0 = input.interp2.xyzw;
                                                                                            output.color = input.interp3.xyzw;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }


                                                                                        // --------------------------------------------------
                                                                                        // Graph

                                                                                        // Graph Properties
                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                        float4 _MainTex_TexelSize;
                                                                                        float _DefaultXRot;
                                                                                        CBUFFER_END

                                                                                            // Object and Global properties
                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                            TEXTURE2D(_MainTex);
                                                                                            SAMPLER(sampler_MainTex);

                                                                                            // Graph Includes
                                                                                            // GraphIncludes: <None>

                                                                                            // -- Property used by ScenePickingPass
                                                                                            #ifdef SCENEPICKINGPASS
                                                                                            float4 _SelectionID;
                                                                                            #endif

                                                                                            // -- Properties used by SceneSelectionPass
                                                                                            #ifdef SCENESELECTIONPASS
                                                                                            int _ObjectId;
                                                                                            int _PassValue;
                                                                                            #endif

                                                                                            // Graph Functions

                                                                                            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                                                            {
                                                                                                Rotation = radians(Rotation);

                                                                                                float s = sin(Rotation);
                                                                                                float c = cos(Rotation);
                                                                                                float one_minus_c = 1.0 - c;

                                                                                                Axis = normalize(Axis);

                                                                                                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                                                        };

                                                                                                Out = mul(rot_mat,  In);
                                                                                            }

                                                                                            struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                                                                                            {
                                                                                            float3 WorldSpaceNormal;
                                                                                            float3 WorldSpaceTangent;
                                                                                            float3 WorldSpaceBiTangent;
                                                                                            float3 WorldSpacePosition;
                                                                                            };

                                                                                            void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                                                                                            {
                                                                                            float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                                                                                            float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                                                                                            float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                                            Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                                                                                            Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                                            }

                                                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                            {
                                                                                            Out = A * B;
                                                                                            }

                                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                            {
                                                                                            Out = A * B;
                                                                                            }

                                                                                            struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                                                                                            {
                                                                                            float4 VertexColor;
                                                                                            half4 uv0;
                                                                                            };

                                                                                            void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                                                                                            {
                                                                                            UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                                                                                            float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                                                                                            float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                                            Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                                                                                            float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                                                                                            float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                                                                                            float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                                                                                            float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                                                                                            float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                                            Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                                                                                            Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                                            Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                                            }

                                                                                            // Custom interpolators pre vertex
                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                            // Graph Vertex
                                                                                            struct VertexDescription
                                                                                            {
                                                                                                float3 Position;
                                                                                                float3 Normal;
                                                                                                float3 Tangent;
                                                                                            };

                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                            {
                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                                                                                                Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                                                                                                float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                                SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                                                                                                description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                return description;
                                                                                            }

                                                                                            // Custom interpolators, pre surface
                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                            {
                                                                                            return output;
                                                                                            }
                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                            #endif

                                                                                            // Graph Pixel
                                                                                            struct SurfaceDescription
                                                                                            {
                                                                                                float3 NormalTS;
                                                                                                float Alpha;
                                                                                                float AlphaClipThreshold;
                                                                                            };

                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                            {
                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                                Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                                                                                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                                                                                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                                                                                                float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                                                                                                float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                                SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                                                                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                                                                surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                                surface.AlphaClipThreshold = 0.1;
                                                                                                return surface;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Build Graph Inputs
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                            #endif
                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                            {
                                                                                                VertexDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                                                output.ObjectSpacePosition = input.positionOS;
                                                                                                output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                                                                                                return output;
                                                                                            }
                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                            {
                                                                                                SurfaceDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                            #endif





                                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                                output.uv0 = input.texCoord0;
                                                                                                output.VertexColor = input.color;
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                            #else
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                            #endif
                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                    return output;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Main

                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                                                                            // --------------------------------------------------
                                                                                            // Visual Effect Vertex Invocations
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                            #endif

                                                                                            ENDHLSL
                                                                                            }
                                                                                            Pass
                                                                                            {
                                                                                                Name "Meta"
                                                                                                Tags
                                                                                                {
                                                                                                    "LightMode" = "Meta"
                                                                                                }

                                                                                                // Render State
                                                                                                Cull Off

                                                                                                // Debug
                                                                                                // <None>

                                                                                                // --------------------------------------------------
                                                                                                // Pass

                                                                                                HLSLPROGRAM

                                                                                                // Pragmas
                                                                                                #pragma target 2.0
                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                #pragma vertex vert
                                                                                                #pragma fragment frag

                                                                                                // DotsInstancingOptions: <None>
                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                // Keywords
                                                                                                #pragma shader_feature _ EDITOR_VISUALIZATION
                                                                                                // GraphKeywords: <None>

                                                                                                // Defines

                                                                                                #define _NORMALMAP 1
                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                                                                #define ATTRIBUTES_NEED_COLOR
                                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                                #define VARYINGS_NEED_TEXCOORD1
                                                                                                #define VARYINGS_NEED_TEXCOORD2
                                                                                                #define VARYINGS_NEED_COLOR
                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                #define SHADERPASS SHADERPASS_META
                                                                                                #define _FOG_FRAGMENT 1
                                                                                                #define _ALPHATEST_ON 1
                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                // custom interpolator pre-include
                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                // Includes
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                // --------------------------------------------------
                                                                                                // Structs and Packing

                                                                                                // custom interpolators pre packing
                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                struct Attributes
                                                                                                {
                                                                                                     float3 positionOS : POSITION;
                                                                                                     float3 normalOS : NORMAL;
                                                                                                     float4 tangentOS : TANGENT;
                                                                                                     float4 uv0 : TEXCOORD0;
                                                                                                     float4 uv1 : TEXCOORD1;
                                                                                                     float4 uv2 : TEXCOORD2;
                                                                                                     float4 color : COLOR;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct Varyings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                     float4 texCoord0;
                                                                                                     float4 texCoord1;
                                                                                                     float4 texCoord2;
                                                                                                     float4 color;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct SurfaceDescriptionInputs
                                                                                                {
                                                                                                     float4 uv0;
                                                                                                     float4 VertexColor;
                                                                                                };
                                                                                                struct VertexDescriptionInputs
                                                                                                {
                                                                                                     float3 ObjectSpaceNormal;
                                                                                                     float3 WorldSpaceNormal;
                                                                                                     float3 ObjectSpaceTangent;
                                                                                                     float3 WorldSpaceTangent;
                                                                                                     float3 ObjectSpaceBiTangent;
                                                                                                     float3 WorldSpaceBiTangent;
                                                                                                     float3 ObjectSpacePosition;
                                                                                                     float3 WorldSpacePosition;
                                                                                                };
                                                                                                struct PackedVaryings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                     float4 interp0 : INTERP0;
                                                                                                     float4 interp1 : INTERP1;
                                                                                                     float4 interp2 : INTERP2;
                                                                                                     float4 interp3 : INTERP3;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };

                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                {
                                                                                                    PackedVaryings output;
                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    output.interp0.xyzw = input.texCoord0;
                                                                                                    output.interp1.xyzw = input.texCoord1;
                                                                                                    output.interp2.xyzw = input.texCoord2;
                                                                                                    output.interp3.xyzw = input.color;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }

                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                {
                                                                                                    Varyings output;
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    output.texCoord0 = input.interp0.xyzw;
                                                                                                    output.texCoord1 = input.interp1.xyzw;
                                                                                                    output.texCoord2 = input.interp2.xyzw;
                                                                                                    output.color = input.interp3.xyzw;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }


                                                                                                // --------------------------------------------------
                                                                                                // Graph

                                                                                                // Graph Properties
                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                float4 _MainTex_TexelSize;
                                                                                                float _DefaultXRot;
                                                                                                CBUFFER_END

                                                                                                    // Object and Global properties
                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                    TEXTURE2D(_MainTex);
                                                                                                    SAMPLER(sampler_MainTex);

                                                                                                    // Graph Includes
                                                                                                    // GraphIncludes: <None>

                                                                                                    // -- Property used by ScenePickingPass
                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                    float4 _SelectionID;
                                                                                                    #endif

                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                    int _ObjectId;
                                                                                                    int _PassValue;
                                                                                                    #endif

                                                                                                    // Graph Functions

                                                                                                    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                                                                    {
                                                                                                        Rotation = radians(Rotation);

                                                                                                        float s = sin(Rotation);
                                                                                                        float c = cos(Rotation);
                                                                                                        float one_minus_c = 1.0 - c;

                                                                                                        Axis = normalize(Axis);

                                                                                                        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                                                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                                                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                                                                };

                                                                                                        Out = mul(rot_mat,  In);
                                                                                                    }

                                                                                                    struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                                                                                                    {
                                                                                                    float3 WorldSpaceNormal;
                                                                                                    float3 WorldSpaceTangent;
                                                                                                    float3 WorldSpaceBiTangent;
                                                                                                    float3 WorldSpacePosition;
                                                                                                    };

                                                                                                    void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                                                                                                    {
                                                                                                    float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                                                                                                    float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                                                                                                    float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                                                    Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                                                                                                    Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                                                    }

                                                                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                                    {
                                                                                                    Out = A * B;
                                                                                                    }

                                                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                    Out = A * B;
                                                                                                    }

                                                                                                    struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                                                                                                    {
                                                                                                    float4 VertexColor;
                                                                                                    half4 uv0;
                                                                                                    };

                                                                                                    void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                                                                                                    {
                                                                                                    UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                                                                                                    float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                                                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                                                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                                                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                                                                                                    float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                                                    Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                                                                                                    float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                                                                                                    float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                                                                                                    float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                                                                                                    float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                                                                                                    float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                                                    Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                                                                                                    Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                                                    Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                                                    }

                                                                                                    // Custom interpolators pre vertex
                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                    // Graph Vertex
                                                                                                    struct VertexDescription
                                                                                                    {
                                                                                                        float3 Position;
                                                                                                        float3 Normal;
                                                                                                        float3 Tangent;
                                                                                                    };

                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                    {
                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                        float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                                                                                                        Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                                                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                                                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                                                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                                                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                                                                                                        float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                                        SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                                                                                                        description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                        return description;
                                                                                                    }

                                                                                                    // Custom interpolators, pre surface
                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                    {
                                                                                                    return output;
                                                                                                    }
                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                    #endif

                                                                                                    // Graph Pixel
                                                                                                    struct SurfaceDescription
                                                                                                    {
                                                                                                        float3 BaseColor;
                                                                                                        float3 Emission;
                                                                                                        float Alpha;
                                                                                                        float AlphaClipThreshold;
                                                                                                    };

                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                    {
                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                        UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                                        Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                                                                                                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                                                                                                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                                                                                                        float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                                                                                                        float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                                        SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                                                                                                        surface.BaseColor = (_SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2.xyz);
                                                                                                        surface.Emission = float3(0, 0, 0);
                                                                                                        surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                                        surface.AlphaClipThreshold = 0.1;
                                                                                                        return surface;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Build Graph Inputs
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                    #endif
                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                    {
                                                                                                        VertexDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                                                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                                                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                                                        output.ObjectSpacePosition = input.positionOS;
                                                                                                        output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                                                                                                        return output;
                                                                                                    }
                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                    {
                                                                                                        SurfaceDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                    #endif







                                                                                                        output.uv0 = input.texCoord0;
                                                                                                        output.VertexColor = input.color;
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                    #else
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                    #endif
                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                            return output;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Main

                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                                                                    // --------------------------------------------------
                                                                                                    // Visual Effect Vertex Invocations
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                    #endif

                                                                                                    ENDHLSL
                                                                                                    }
                                                                                                    Pass
                                                                                                    {
                                                                                                        Name "SceneSelectionPass"
                                                                                                        Tags
                                                                                                        {
                                                                                                            "LightMode" = "SceneSelectionPass"
                                                                                                        }

                                                                                                        // Render State
                                                                                                        Cull Off

                                                                                                        // Debug
                                                                                                        // <None>

                                                                                                        // --------------------------------------------------
                                                                                                        // Pass

                                                                                                        HLSLPROGRAM

                                                                                                        // Pragmas
                                                                                                        #pragma target 2.0
                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                        #pragma multi_compile_instancing
                                                                                                        #pragma vertex vert
                                                                                                        #pragma fragment frag

                                                                                                        // DotsInstancingOptions: <None>
                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                        // Keywords
                                                                                                        // PassKeywords: <None>
                                                                                                        // GraphKeywords: <None>

                                                                                                        // Defines

                                                                                                        #define _NORMALMAP 1
                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                        #define ATTRIBUTES_NEED_COLOR
                                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                                        #define VARYINGS_NEED_COLOR
                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                        #define SCENESELECTIONPASS 1
                                                                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                                                                        #define _ALPHATEST_ON 1
                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                        // custom interpolator pre-include
                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                        // Includes
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                        // --------------------------------------------------
                                                                                                        // Structs and Packing

                                                                                                        // custom interpolators pre packing
                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                        struct Attributes
                                                                                                        {
                                                                                                             float3 positionOS : POSITION;
                                                                                                             float3 normalOS : NORMAL;
                                                                                                             float4 tangentOS : TANGENT;
                                                                                                             float4 uv0 : TEXCOORD0;
                                                                                                             float4 color : COLOR;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct Varyings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float4 texCoord0;
                                                                                                             float4 color;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct SurfaceDescriptionInputs
                                                                                                        {
                                                                                                             float4 uv0;
                                                                                                             float4 VertexColor;
                                                                                                        };
                                                                                                        struct VertexDescriptionInputs
                                                                                                        {
                                                                                                             float3 ObjectSpaceNormal;
                                                                                                             float3 WorldSpaceNormal;
                                                                                                             float3 ObjectSpaceTangent;
                                                                                                             float3 WorldSpaceTangent;
                                                                                                             float3 ObjectSpaceBiTangent;
                                                                                                             float3 WorldSpaceBiTangent;
                                                                                                             float3 ObjectSpacePosition;
                                                                                                             float3 WorldSpacePosition;
                                                                                                        };
                                                                                                        struct PackedVaryings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float4 interp0 : INTERP0;
                                                                                                             float4 interp1 : INTERP1;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };

                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                        {
                                                                                                            PackedVaryings output;
                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.interp0.xyzw = input.texCoord0;
                                                                                                            output.interp1.xyzw = input.color;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }

                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                        {
                                                                                                            Varyings output;
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.texCoord0 = input.interp0.xyzw;
                                                                                                            output.color = input.interp1.xyzw;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }


                                                                                                        // --------------------------------------------------
                                                                                                        // Graph

                                                                                                        // Graph Properties
                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                        float4 _MainTex_TexelSize;
                                                                                                        float _DefaultXRot;
                                                                                                        CBUFFER_END

                                                                                                            // Object and Global properties
                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                            TEXTURE2D(_MainTex);
                                                                                                            SAMPLER(sampler_MainTex);

                                                                                                            // Graph Includes
                                                                                                            // GraphIncludes: <None>

                                                                                                            // -- Property used by ScenePickingPass
                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                            float4 _SelectionID;
                                                                                                            #endif

                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                            int _ObjectId;
                                                                                                            int _PassValue;
                                                                                                            #endif

                                                                                                            // Graph Functions

                                                                                                            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                                                                            {
                                                                                                                Rotation = radians(Rotation);

                                                                                                                float s = sin(Rotation);
                                                                                                                float c = cos(Rotation);
                                                                                                                float one_minus_c = 1.0 - c;

                                                                                                                Axis = normalize(Axis);

                                                                                                                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                                                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                                                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                                                                        };

                                                                                                                Out = mul(rot_mat,  In);
                                                                                                            }

                                                                                                            struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                                                                                                            {
                                                                                                            float3 WorldSpaceNormal;
                                                                                                            float3 WorldSpaceTangent;
                                                                                                            float3 WorldSpaceBiTangent;
                                                                                                            float3 WorldSpacePosition;
                                                                                                            };

                                                                                                            void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                                                                                                            {
                                                                                                            float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                                                                                                            float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                                                                                                            float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                                                            Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                                                                                                            Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                                                            }

                                                                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                                            {
                                                                                                            Out = A * B;
                                                                                                            }

                                                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                            Out = A * B;
                                                                                                            }

                                                                                                            struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                                                                                                            {
                                                                                                            float4 VertexColor;
                                                                                                            half4 uv0;
                                                                                                            };

                                                                                                            void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                                                                                                            {
                                                                                                            UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                                                                                                            float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                                                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                                                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                                                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                                                                                                            float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                                                            Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                                                                                                            float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                                                                                                            float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                                                                                                            float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                                                                                                            float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                                                                                                            float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                                                            Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                                                                                                            Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                                                            Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                                                            }

                                                                                                            // Custom interpolators pre vertex
                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                            // Graph Vertex
                                                                                                            struct VertexDescription
                                                                                                            {
                                                                                                                float3 Position;
                                                                                                                float3 Normal;
                                                                                                                float3 Tangent;
                                                                                                            };

                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                            {
                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                                                                                                                Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                                                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                                                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                                                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                                                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                                                                                                                float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                                                SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                                                                                                                description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                return description;
                                                                                                            }

                                                                                                            // Custom interpolators, pre surface
                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                            {
                                                                                                            return output;
                                                                                                            }
                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                            #endif

                                                                                                            // Graph Pixel
                                                                                                            struct SurfaceDescription
                                                                                                            {
                                                                                                                float Alpha;
                                                                                                                float AlphaClipThreshold;
                                                                                                            };

                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                            {
                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                                                Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                                                                                                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                                                                                                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                                                                                                                float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                                                                                                                float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                                                SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                                                                                                                surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                                                surface.AlphaClipThreshold = 0.1;
                                                                                                                return surface;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Build Graph Inputs
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                            #endif
                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                            {
                                                                                                                VertexDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                                                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                                                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                                                                output.ObjectSpacePosition = input.positionOS;
                                                                                                                output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                                                                                                                return output;
                                                                                                            }
                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                            {
                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                            #endif







                                                                                                                output.uv0 = input.texCoord0;
                                                                                                                output.VertexColor = input.color;
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                            #else
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                            #endif
                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                    return output;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Main

                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                            // --------------------------------------------------
                                                                                                            // Visual Effect Vertex Invocations
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                            #endif

                                                                                                            ENDHLSL
                                                                                                            }
                                                                                                            Pass
                                                                                                            {
                                                                                                                Name "ScenePickingPass"
                                                                                                                Tags
                                                                                                                {
                                                                                                                    "LightMode" = "Picking"
                                                                                                                }

                                                                                                                // Render State
                                                                                                                Cull Off

                                                                                                                // Debug
                                                                                                                // <None>

                                                                                                                // --------------------------------------------------
                                                                                                                // Pass

                                                                                                                HLSLPROGRAM

                                                                                                                // Pragmas
                                                                                                                #pragma target 2.0
                                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                #pragma multi_compile_instancing
                                                                                                                #pragma vertex vert
                                                                                                                #pragma fragment frag

                                                                                                                // DotsInstancingOptions: <None>
                                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                // Keywords
                                                                                                                // PassKeywords: <None>
                                                                                                                // GraphKeywords: <None>

                                                                                                                // Defines

                                                                                                                #define _NORMALMAP 1
                                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                                #define ATTRIBUTES_NEED_COLOR
                                                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                                                #define VARYINGS_NEED_COLOR
                                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                                #define SCENEPICKINGPASS 1
                                                                                                                #define ALPHA_CLIP_THRESHOLD 1
                                                                                                                #define _ALPHATEST_ON 1
                                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                // custom interpolator pre-include
                                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                // Includes
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                // --------------------------------------------------
                                                                                                                // Structs and Packing

                                                                                                                // custom interpolators pre packing
                                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                struct Attributes
                                                                                                                {
                                                                                                                     float3 positionOS : POSITION;
                                                                                                                     float3 normalOS : NORMAL;
                                                                                                                     float4 tangentOS : TANGENT;
                                                                                                                     float4 uv0 : TEXCOORD0;
                                                                                                                     float4 color : COLOR;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct Varyings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float4 texCoord0;
                                                                                                                     float4 color;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct SurfaceDescriptionInputs
                                                                                                                {
                                                                                                                     float4 uv0;
                                                                                                                     float4 VertexColor;
                                                                                                                };
                                                                                                                struct VertexDescriptionInputs
                                                                                                                {
                                                                                                                     float3 ObjectSpaceNormal;
                                                                                                                     float3 WorldSpaceNormal;
                                                                                                                     float3 ObjectSpaceTangent;
                                                                                                                     float3 WorldSpaceTangent;
                                                                                                                     float3 ObjectSpaceBiTangent;
                                                                                                                     float3 WorldSpaceBiTangent;
                                                                                                                     float3 ObjectSpacePosition;
                                                                                                                     float3 WorldSpacePosition;
                                                                                                                };
                                                                                                                struct PackedVaryings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float4 interp0 : INTERP0;
                                                                                                                     float4 interp1 : INTERP1;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };

                                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                                {
                                                                                                                    PackedVaryings output;
                                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.interp0.xyzw = input.texCoord0;
                                                                                                                    output.interp1.xyzw = input.color;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }

                                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                {
                                                                                                                    Varyings output;
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.texCoord0 = input.interp0.xyzw;
                                                                                                                    output.color = input.interp1.xyzw;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }


                                                                                                                // --------------------------------------------------
                                                                                                                // Graph

                                                                                                                // Graph Properties
                                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                                float4 _MainTex_TexelSize;
                                                                                                                float _DefaultXRot;
                                                                                                                CBUFFER_END

                                                                                                                    // Object and Global properties
                                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                    TEXTURE2D(_MainTex);
                                                                                                                    SAMPLER(sampler_MainTex);

                                                                                                                    // Graph Includes
                                                                                                                    // GraphIncludes: <None>

                                                                                                                    // -- Property used by ScenePickingPass
                                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                                    float4 _SelectionID;
                                                                                                                    #endif

                                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                                    int _ObjectId;
                                                                                                                    int _PassValue;
                                                                                                                    #endif

                                                                                                                    // Graph Functions

                                                                                                                    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                                                                                    {
                                                                                                                        Rotation = radians(Rotation);

                                                                                                                        float s = sin(Rotation);
                                                                                                                        float c = cos(Rotation);
                                                                                                                        float one_minus_c = 1.0 - c;

                                                                                                                        Axis = normalize(Axis);

                                                                                                                        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                                                                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                                                                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                                                                                };

                                                                                                                        Out = mul(rot_mat,  In);
                                                                                                                    }

                                                                                                                    struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                                                                                                                    {
                                                                                                                    float3 WorldSpaceNormal;
                                                                                                                    float3 WorldSpaceTangent;
                                                                                                                    float3 WorldSpaceBiTangent;
                                                                                                                    float3 WorldSpacePosition;
                                                                                                                    };

                                                                                                                    void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                                                                                                                    {
                                                                                                                    float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                                                                                                                    float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                                                                                                                    float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                                                                    Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                                                                                                                    Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                                                                    }

                                                                                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                                                    {
                                                                                                                    Out = A * B;
                                                                                                                    }

                                                                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                    Out = A * B;
                                                                                                                    }

                                                                                                                    struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                                                                                                                    {
                                                                                                                    float4 VertexColor;
                                                                                                                    half4 uv0;
                                                                                                                    };

                                                                                                                    void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                                                                                                                    {
                                                                                                                    UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                                                                                                                    float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                                                                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                                                                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                                                                                                                    float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                                                                                                                    float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                                                                    Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                                                                                                                    float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                                                                                                                    float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                                                                                                                    float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                                                                                                                    float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                                                                                                                    float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                                                                    Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                                                                                                                    Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                                                                    Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                                                                    }

                                                                                                                    // Custom interpolators pre vertex
                                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                    // Graph Vertex
                                                                                                                    struct VertexDescription
                                                                                                                    {
                                                                                                                        float3 Position;
                                                                                                                        float3 Normal;
                                                                                                                        float3 Tangent;
                                                                                                                    };

                                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                                        float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                                                                                                                        Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                                                                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                                                                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                                                                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                                                                                                                        _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                                                                                                                        float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                                                        SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                                                                                                                        description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                        return description;
                                                                                                                    }

                                                                                                                    // Custom interpolators, pre surface
                                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                    {
                                                                                                                    return output;
                                                                                                                    }
                                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                    #endif

                                                                                                                    // Graph Pixel
                                                                                                                    struct SurfaceDescription
                                                                                                                    {
                                                                                                                        float Alpha;
                                                                                                                        float AlphaClipThreshold;
                                                                                                                    };

                                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                        UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                                                        Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                                                                                                                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                                                                                                                        _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                                                                                                                        float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                                                                                                                        float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                                                        SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                                                                                                                        surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                                                        surface.AlphaClipThreshold = 0.1;
                                                                                                                        return surface;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Build Graph Inputs
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                    #endif
                                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                    {
                                                                                                                        VertexDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                                                                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                                                                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                                                                        output.ObjectSpacePosition = input.positionOS;
                                                                                                                        output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                                                                                                                        return output;
                                                                                                                    }
                                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                    {
                                                                                                                        SurfaceDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                    #endif







                                                                                                                        output.uv0 = input.texCoord0;
                                                                                                                        output.VertexColor = input.color;
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                    #else
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                    #endif
                                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                            return output;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Main

                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Visual Effect Vertex Invocations
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                    #endif

                                                                                                                    ENDHLSL
                                                                                                                    }
                                                                                                                    Pass
                                                                                                                    {
                                                                                                                        // Name: <None>
                                                                                                                        Tags
                                                                                                                        {
                                                                                                                            "LightMode" = "Universal2D"
                                                                                                                        }

                                                                                                                        // Render State
                                                                                                                        Cull Off
                                                                                                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                                                                        ZTest LEqual
                                                                                                                        ZWrite Off

                                                                                                                        // Debug
                                                                                                                        // <None>

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Pass

                                                                                                                        HLSLPROGRAM

                                                                                                                        // Pragmas
                                                                                                                        #pragma target 2.0
                                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                        #pragma multi_compile_instancing
                                                                                                                        #pragma vertex vert
                                                                                                                        #pragma fragment frag

                                                                                                                        // DotsInstancingOptions: <None>
                                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                        // Keywords
                                                                                                                        // PassKeywords: <None>
                                                                                                                        // GraphKeywords: <None>

                                                                                                                        // Defines

                                                                                                                        #define _NORMALMAP 1
                                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                                        #define ATTRIBUTES_NEED_COLOR
                                                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                                                        #define VARYINGS_NEED_COLOR
                                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                        #define SHADERPASS SHADERPASS_2D
                                                                                                                        #define _ALPHATEST_ON 1
                                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                        // custom interpolator pre-include
                                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                        // Includes
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Structs and Packing

                                                                                                                        // custom interpolators pre packing
                                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                        struct Attributes
                                                                                                                        {
                                                                                                                             float3 positionOS : POSITION;
                                                                                                                             float3 normalOS : NORMAL;
                                                                                                                             float4 tangentOS : TANGENT;
                                                                                                                             float4 uv0 : TEXCOORD0;
                                                                                                                             float4 color : COLOR;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct Varyings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                             float4 texCoord0;
                                                                                                                             float4 color;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct SurfaceDescriptionInputs
                                                                                                                        {
                                                                                                                             float4 uv0;
                                                                                                                             float4 VertexColor;
                                                                                                                        };
                                                                                                                        struct VertexDescriptionInputs
                                                                                                                        {
                                                                                                                             float3 ObjectSpaceNormal;
                                                                                                                             float3 WorldSpaceNormal;
                                                                                                                             float3 ObjectSpaceTangent;
                                                                                                                             float3 WorldSpaceTangent;
                                                                                                                             float3 ObjectSpaceBiTangent;
                                                                                                                             float3 WorldSpaceBiTangent;
                                                                                                                             float3 ObjectSpacePosition;
                                                                                                                             float3 WorldSpacePosition;
                                                                                                                        };
                                                                                                                        struct PackedVaryings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                             float4 interp0 : INTERP0;
                                                                                                                             float4 interp1 : INTERP1;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };

                                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                                        {
                                                                                                                            PackedVaryings output;
                                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            output.interp0.xyzw = input.texCoord0;
                                                                                                                            output.interp1.xyzw = input.color;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }

                                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                        {
                                                                                                                            Varyings output;
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            output.texCoord0 = input.interp0.xyzw;
                                                                                                                            output.color = input.interp1.xyzw;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }


                                                                                                                        // --------------------------------------------------
                                                                                                                        // Graph

                                                                                                                        // Graph Properties
                                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                                        float4 _MainTex_TexelSize;
                                                                                                                        float _DefaultXRot;
                                                                                                                        CBUFFER_END

                                                                                                                            // Object and Global properties
                                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                            TEXTURE2D(_MainTex);
                                                                                                                            SAMPLER(sampler_MainTex);

                                                                                                                            // Graph Includes
                                                                                                                            // GraphIncludes: <None>

                                                                                                                            // -- Property used by ScenePickingPass
                                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                                            float4 _SelectionID;
                                                                                                                            #endif

                                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                                            int _ObjectId;
                                                                                                                            int _PassValue;
                                                                                                                            #endif

                                                                                                                            // Graph Functions

                                                                                                                            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                                                                                            {
                                                                                                                                Rotation = radians(Rotation);

                                                                                                                                float s = sin(Rotation);
                                                                                                                                float c = cos(Rotation);
                                                                                                                                float one_minus_c = 1.0 - c;

                                                                                                                                Axis = normalize(Axis);

                                                                                                                                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                                                                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                                                                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                                                                                        };

                                                                                                                                Out = mul(rot_mat,  In);
                                                                                                                            }

                                                                                                                            struct Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float
                                                                                                                            {
                                                                                                                            float3 WorldSpaceNormal;
                                                                                                                            float3 WorldSpaceTangent;
                                                                                                                            float3 WorldSpaceBiTangent;
                                                                                                                            float3 WorldSpacePosition;
                                                                                                                            };

                                                                                                                            void SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(float _DefaultXRot, Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float IN, out float3 Position_Object_Space_1)
                                                                                                                            {
                                                                                                                            float3 _Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1 = TransformWorldToObject(IN.WorldSpacePosition.xyz);
                                                                                                                            float _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0 = _DefaultXRot;
                                                                                                                            float3 _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                                                                            Unity_Rotate_About_Axis_Degrees_float(_Transform_1f2cef7dc058402cbca8cccb70c765d7_Out_1, float3 (1, 0, 0), _Property_2cd3909241d849fa9bd71e9232bb7942_Out_0, _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3);
                                                                                                                            Position_Object_Space_1 = _RotateAboutAxis_f3c7c555ea194dedb436f94238c5435f_Out_3;
                                                                                                                            }

                                                                                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                                                            {
                                                                                                                            Out = A * B;
                                                                                                                            }

                                                                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                                            {
                                                                                                                            Out = A * B;
                                                                                                                            }

                                                                                                                            struct Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float
                                                                                                                            {
                                                                                                                            float4 VertexColor;
                                                                                                                            half4 uv0;
                                                                                                                            };

                                                                                                                            void SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(UnityTexture2D _MainTex, Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float IN, out float4 Color_2, out float Alpha_1)
                                                                                                                            {
                                                                                                                            UnityTexture2D _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0 = _MainTex;
                                                                                                                            float4 _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.tex, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.samplerstate, _Property_342f0d752c464e488d8d4c8f16a4b820_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_R_4 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.r;
                                                                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_G_5 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.g;
                                                                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_B_6 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.b;
                                                                                                                            float _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7 = _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0.a;
                                                                                                                            float4 _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                                                                            Unity_Multiply_float4_float4(IN.VertexColor, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_RGBA_0, _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2);
                                                                                                                            float _Split_1d1517929aab48d1bac619aee7042581_R_1 = IN.VertexColor[0];
                                                                                                                            float _Split_1d1517929aab48d1bac619aee7042581_G_2 = IN.VertexColor[1];
                                                                                                                            float _Split_1d1517929aab48d1bac619aee7042581_B_3 = IN.VertexColor[2];
                                                                                                                            float _Split_1d1517929aab48d1bac619aee7042581_A_4 = IN.VertexColor[3];
                                                                                                                            float _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                                                                            Unity_Multiply_float_float(_Split_1d1517929aab48d1bac619aee7042581_A_4, _SampleTexture2D_89fa309fb3304c10a26cdf592bdb4e10_A_7, _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2);
                                                                                                                            Color_2 = _Multiply_376c8ba951644c0fbe5886175582bcb0_Out_2;
                                                                                                                            Alpha_1 = _Multiply_a4e872d85ecc43a5a825c2442c088e88_Out_2;
                                                                                                                            }

                                                                                                                            // Custom interpolators pre vertex
                                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                            // Graph Vertex
                                                                                                                            struct VertexDescription
                                                                                                                            {
                                                                                                                                float3 Position;
                                                                                                                                float3 Normal;
                                                                                                                                float3 Tangent;
                                                                                                                            };

                                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                                float _Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0 = _DefaultXRot;
                                                                                                                                Bindings_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa;
                                                                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceNormal = IN.WorldSpaceNormal;
                                                                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceTangent = IN.WorldSpaceTangent;
                                                                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                                                                                                                                _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa.WorldSpacePosition = IN.WorldSpacePosition;
                                                                                                                                float3 _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                                                                SG_RotateAroundX_3ec6039d065928e4fbb227982080fb50_float(_Property_e2bf0ec678194c8cb242faa1bbc80b63_Out_0, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa, _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1);
                                                                                                                                description.Position = _RotateAroundX_24ec1210e39d46a1b298bd2572452dfa_PositionObjectSpace_1;
                                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                                return description;
                                                                                                                            }

                                                                                                                            // Custom interpolators, pre surface
                                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                            {
                                                                                                                            return output;
                                                                                                                            }
                                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                            #endif

                                                                                                                            // Graph Pixel
                                                                                                                            struct SurfaceDescription
                                                                                                                            {
                                                                                                                                float3 BaseColor;
                                                                                                                                float Alpha;
                                                                                                                                float AlphaClipThreshold;
                                                                                                                            };

                                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                                UnityTexture2D _Property_6bdef01566ec43558f71466dfb6c7816_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                                                                Bindings_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef;
                                                                                                                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.VertexColor = IN.VertexColor;
                                                                                                                                _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef.uv0 = IN.uv0;
                                                                                                                                float4 _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2;
                                                                                                                                float _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                                                                SG_SpriteSampleAndBlend_4724c2f502e1c604b9882482c04ab318_float(_Property_6bdef01566ec43558f71466dfb6c7816_Out_0, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2, _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1);
                                                                                                                                surface.BaseColor = (_SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Color_2.xyz);
                                                                                                                                surface.Alpha = _SpriteSampleAndBlend_8bd6b86aaf014c46a9a5f19dc77956ef_Alpha_1;
                                                                                                                                surface.AlphaClipThreshold = 0.1;
                                                                                                                                return surface;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Build Graph Inputs
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                            #endif
                                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                            {
                                                                                                                                VertexDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                                                                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                                                                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                                                                                output.ObjectSpacePosition = input.positionOS;
                                                                                                                                output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);

                                                                                                                                return output;
                                                                                                                            }
                                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                            {
                                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                            #endif







                                                                                                                                output.uv0 = input.texCoord0;
                                                                                                                                output.VertexColor = input.color;
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                            #else
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                            #endif
                                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                                    return output;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Main

                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Visual Effect Vertex Invocations
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                            #endif

                                                                                                                            ENDHLSL
                                                                                                                            }
                                                                    }
                                                                        CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
                                                                                                                                CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                                                                                FallBack "Hidden/Shader Graph/FallbackError"
}