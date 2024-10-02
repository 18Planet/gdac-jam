using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CameraShake : MonoBehaviour
{
    public static CameraShake instance;

    [SerializeField] public CinemachineImpulseSource source;

    private void Awake()
    {
        instance = this;
    }

    public void CreateImpulse(Vector3 direction, float duration = 0.4f)
    {
        source.m_DefaultVelocity = direction;
        source.m_ImpulseDefinition.m_ImpulseDuration = duration;
        source.GenerateImpulse();
    }

    public void CreateImpulse(float magnitude, float duration)
    {
        CreateImpulse(Random.insideUnitCircle * magnitude, duration);
    }
}
