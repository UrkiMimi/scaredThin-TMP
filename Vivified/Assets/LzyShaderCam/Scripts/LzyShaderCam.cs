using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class LzyShaderCam : MonoBehaviour
{
    //params
    [Header("Required")]
    [SerializeField]
    private Shader _mainShader;

    [SerializeField]
    private Shader _blurShader;

    [Space]
    [Header("Properties")]
    [SerializeField]
    private float _Intensity = 1f;

    [SerializeField]
    private float _Threshold = 1;

    [SerializeField]
    [Range(2,16)]
    private int _Iterations = 4;

    [Range(4,8)]
    [SerializeField]
    private int _DirectionCount = 8;

    [SerializeField]
    private float _KernelSize = 0.25f;


    [Space]
    [Header("Debugging")]
    [SerializeField]
    private bool _RenderBloomLayerOnly = false;

    [SerializeField]
    private int TextureSize = 1024;

    //global vars
    private Material mat;

    private Material blurMat;

    // called on render
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Camera camera = Camera.main;

        //create and blur secondary texture
        RenderTexture tmp = blurTexture(source, null);

        // only render if material is present
        if (mat != null)
        {

            mat.SetFloat("_BIntensity", _Intensity);
            mat.SetFloat("_BThreshold", _Threshold);
            //mat.SetInt("_BIteration", _Iterations);
            //mat.SetFloat("_BKSize", _KernelSize);
            //mat.SetInt("_BDirCount", _DirectionCount);
            mat.SetTexture("_BTex", tmp);
            EnableKeywordBasedOnBoolean(mat, _RenderBloomLayerOnly, "BLUR_ONLY_ENABLED");
            Graphics.Blit(source, destination, mat, 0);
        }
        RenderTexture.ReleaseTemporary(tmp);
    }

    // for debugging shader
    private void EnableKeywordBasedOnBoolean(Material material, bool boolean, string keyword)
    {
        if (boolean)
        {
            material.EnableKeyword(keyword);
        }
        else
        {
            material.DisableKeyword(keyword);
        }
    }

    private RenderTexture blurTexture(RenderTexture source, RenderTexture destination)
    {
        // setup
        RenderTextureDescriptor desc = new RenderTextureDescriptor(TextureSize, TextureSize, RenderTextureFormat.ARGB32, 0);
        RenderTexture tmp1 = RenderTexture.GetTemporary(desc);
        RenderTexture tmp2 = RenderTexture.GetTemporary(desc);
        Graphics.Blit(source, tmp1); // draw to first texture


        blurMat.SetTexture("_MainTex", tmp1);
        blurMat.SetFloat("_BKSize", _KernelSize);
        blurMat.SetFloat("_DirSize", _DirectionCount);
        blurMat.SetFloat("_BIterations", _Iterations);


        //blit the texture
        for (int i = 0; i < _Iterations; i++)
        {
            Graphics.Blit(tmp1, tmp2, blurMat);
            blurMat.SetTexture("_MainTex", tmp1);
            var tmp = tmp2;
            tmp2 = tmp1;
            tmp1 = tmp;
        }

        //to not eat shit and die
        // for recycling
        RenderTexture current = tmp1;
        RenderTexture unused = tmp2;


        if ((_Iterations % 2) == 1)
        {
            current = tmp2;
            unused = tmp1;
        }

        // release to reduce ram leaks
        RenderTexture.ReleaseTemporary(unused);
        return current;
    }

    void Start()
    {
        if (_mainShader == null || _blurShader == null)
        {
            Debug.LogError("Please assign a shader into both slots before use!");
        }

        // create materials
        if (mat == null)
        {
            mat = new Material(_mainShader);
        }

        if (blurMat == null)
        {
            blurMat = new Material(_blurShader);
        }
    }
}
