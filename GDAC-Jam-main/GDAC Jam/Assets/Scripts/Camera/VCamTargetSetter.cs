using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
public class VCamTargetSetter : MonoBehaviour
{
    private void Awake()
    {
        this.GetComponent<CinemachineVirtualCamera>().Follow = FindObjectOfType<PlayerManager>().PlayerTransform;
    }
}
