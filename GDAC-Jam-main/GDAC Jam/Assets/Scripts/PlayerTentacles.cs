using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using TMPro;

public class PlayerTentacles : MonoBehaviour
{
    Mouse mouse = Mouse.current;

    public GameObject playerBody;

    [SerializeField]
    GameObject tentacle;

    [SerializeField]
    private float baseCooldown;

    [SerializeField]
    private float cooldown;

    [SerializeField]
    private float cdTimer;

    public static float souls;
    public static float soulsToGet;

    private AudioSource au;

    [SerializeField]
    TextMeshProUGUI text;

    // Start is called before the first frame update
    void Start()
    {
        au = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.P))
        {
            var entity = GetComponentInParent<BasicEntity>();
            entity.ReceiveDamage(new AttackData { damage = 1000, knockbackDirection = Vector2.zero, knockbackVelocity = 5f });
        }

        text.text = "Souls: " + souls;
        cooldown = Mathf.Clamp(baseCooldown - (souls / 200), 0.05f, 0.5f);

        cdTimer -= Time.deltaTime;

        if(cdTimer <=0 && mouse.leftButton.IsPressed())
        {
            Vector2 targetPoint = playerBody.transform.InverseTransformPoint(Camera.main.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, 4))) * 2;
            CameraShake.instance.CreateImpulse(((Vector2)playerBody.transform.position - targetPoint).normalized * 0.15f, 0.3f);
            au.PlayOneShot(au.clip);
            cdTimer = cooldown;
            GameObject g = Instantiate(tentacle);
            g.transform.parent = playerBody.transform;
            g.GetComponent<Tentacle>().endpoint.localPosition = targetPoint;
            g.transform.localPosition = Vector3.zero + Vector3.up / 4;
            g.GetComponent<Tentacle>().startPoint.localPosition = g.transform.localPosition;
            g.GetComponent<Tentacle>().shootTentacle = true;
        }
    }
}
