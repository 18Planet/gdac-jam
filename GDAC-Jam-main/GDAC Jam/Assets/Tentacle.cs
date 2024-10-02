using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tentacle : MonoBehaviour
{
    [SerializeField]
    GameObject tentacleParticle;

    [SerializeField]
    private Transform[] controlPoints;

    [SerializeField]
    private float speedModifier;

    [SerializeField]
    private float randomness;

    public Transform startPoint;
    public Transform endpoint;

    public bool shootTentacle;

    [SerializeField]
    GameObject [] particles = new GameObject[20];

    [SerializeField]
    List<BasicEntity> enemiesHit = new List<BasicEntity>();

    // Start is called before the first frame update
    void Awake()
    {
        for (float i = 0; i < 20; i++)
        {
            GameObject g = Instantiate(tentacleParticle);
            particles[(int)i] = g;
            g.transform.parent = this.transform;
            g.transform.localScale = new Vector3(1, 1, 1) * (1 / (i/10 + 1));
        }
    }

    // Update is called once per frame
    void Update()
    {
        int i = 0;
        for (float t = 0; t <= 1; t += 0.05f)
        {
                Debug.DrawRay(GlobalBezier(t), GlobalBezier(t + 0.05f).normalized * Vector2.Distance(GlobalBezier(t + 0.05f), GlobalBezier(t)));
                //Debug.DrawRay(Mathf.Pow(1 - t, 3) * controlPoints[0].position + 3 * Mathf.Pow(1 - t, 2) * t * controlPoints[1].position + 3 * (1 - t) * Mathf.Pow(t, 2) * controlPoints[2].position + Mathf.Pow(t, 3) * controlPoints[3].position,
                //Mathf.Pow(1 - (t + 0.2f), 3) * controlPoints[0].position + 3 * Mathf.Pow(1 - (t + 0.2f), 2) * (t + 0.2f) * controlPoints[1].position + 3 * (1 - (t + 0.2f)) * Mathf.Pow((t + 0.2f), 2) * controlPoints[2].position + Mathf.Pow((t + 0.2f), 3) * controlPoints[3].position);

                LayerMask mask = LayerMask.GetMask("Enemy");
                RaycastHit2D hit = Physics2D.Raycast(GlobalBezier(t), GlobalBezier(t + 0.05f).normalized, Vector2.Distance(GlobalBezier(t + 0.05f), GlobalBezier(t)), mask);

                if (hit.collider != null)
                {
                    var entity = hit.collider.gameObject.GetComponentInParent<BasicEntity>();
                    if (entity != null && !enemiesHit.Contains(entity))
                    {
                        entity.ReceiveDamage(new AttackData { damage = 1, knockbackDirection = endpoint.position - startPoint.position, knockbackVelocity = 5f });
                        enemiesHit.Add(entity);
                        Debug.Log("Hit enemy");
                    }
                }
            particles[i].transform.localPosition = Bezier(t);
            i++;
        }

        if(shootTentacle)
        {
            shootTentacle = false;
            controlPoints[0].transform.localPosition = startPoint.localPosition;
            StartCoroutine(MoveTentacle());
        }
    }

    private IEnumerator MoveTentacle()
    {
        float rand1x = Random.Range(-randomness, randomness);
        float rand1y = Random.Range(-randomness, randomness);
        float rand2x = Random.Range(-randomness, randomness);
        float rand2y = Random.Range(-randomness, randomness);

        float distToEnd = Vector3.Distance(startPoint.localPosition, endpoint.localPosition);
        while (distToEnd >= 0.01)
        {
            controlPoints[3].transform.localPosition = Vector3.MoveTowards(controlPoints[3].transform.localPosition, endpoint.localPosition, speedModifier * Time.deltaTime);
            controlPoints[2].transform.localPosition = (controlPoints[3].transform.localPosition * 2 + controlPoints[0].transform.localPosition) / 2 + new Vector3(rand1x, rand1y, 0);
            controlPoints[1].transform.localPosition = (controlPoints[3].transform.localPosition + controlPoints[0].transform.localPosition * 2) / 2 + new Vector3(rand2x, rand2y, 0);
            distToEnd = Vector3.Distance(controlPoints[3].transform.localPosition, endpoint.localPosition);
            yield return null;
        }

        yield return null;

        float distToStart = Vector3.Distance(endpoint.localPosition, startPoint.localPosition);
        while (distToStart >= 0.01)
        {
            controlPoints[3].transform.localPosition = Vector3.MoveTowards(controlPoints[3].transform.localPosition, startPoint.localPosition, speedModifier * 2 * Time.deltaTime);
            controlPoints[2].transform.localPosition = (controlPoints[3].transform.localPosition * 2 + controlPoints[0].transform.localPosition) / 2 + new Vector3(rand1x, rand1y, 0);
            controlPoints[1].transform.localPosition = (controlPoints[3].transform.localPosition + controlPoints[0].transform.localPosition * 2) / 2 + new Vector3(rand2x, rand2y, 0);
            distToStart = Vector3.Distance(controlPoints[3].transform.localPosition, startPoint.localPosition);
            yield return null;
        }

        foreach(GameObject g in particles)
        {
            g.GetComponent<ParticleSystem>().Stop();
        }

        yield return new WaitForSeconds(1);

        foreach (GameObject g in particles)
        {
            Destroy(g);
        }

        Destroy(this.gameObject);
    }

    public void TentacleHit()
    {
        //RaycastHit2D hit = Physics2D.Raycast(startPoint.position, endpoint.position.normalized * Vector2.Distance(startPoint.position, endpoint.position))

        for(float t = 0; t < 1; t += 0.05f)
        {
            Debug.DrawRay(GlobalBezier(t), GlobalBezier(t + 0.05f).normalized * Vector2.Distance(GlobalBezier(t + 0.05f), GlobalBezier(t)));
            //Debug.DrawRay(Mathf.Pow(1 - t, 3) * controlPoints[0].position + 3 * Mathf.Pow(1 - t, 2) * t * controlPoints[1].position + 3 * (1 - t) * Mathf.Pow(t, 2) * controlPoints[2].position + Mathf.Pow(t, 3) * controlPoints[3].position,
            //Mathf.Pow(1 - (t + 0.2f), 3) * controlPoints[0].position + 3 * Mathf.Pow(1 - (t + 0.2f), 2) * (t + 0.2f) * controlPoints[1].position + 3 * (1 - (t + 0.2f)) * Mathf.Pow((t + 0.2f), 2) * controlPoints[2].position + Mathf.Pow((t + 0.2f), 3) * controlPoints[3].position);

            LayerMask mask = LayerMask.GetMask("Enemy");
            RaycastHit2D hit = Physics2D.Raycast(GlobalBezier(t), GlobalBezier(t + 0.05f).normalized, Vector2.Distance(GlobalBezier(t + 0.05f), GlobalBezier(t)), mask);

            if (hit.collider != null )
            {
                var entity = hit.collider.gameObject.GetComponentInParent<BasicEntity>();
                if (entity != null)
                {
                    entity.ReceiveDamage(new AttackData { damage = 1f * (PlayerTentacles.souls/100), knockbackDirection = endpoint.position - startPoint.position, knockbackVelocity = 5f });
                    Debug.Log("Hit enemy");
                }
            }
        }
    }

    public Vector2 Bezier(float t)
    {
        return Mathf.Pow(1 - t, 3) * controlPoints[0].localPosition + 3 * Mathf.Pow(1 - t, 2) * t * controlPoints[1].localPosition + 3 * (1 - t) * Mathf.Pow(t, 2) * controlPoints[2].localPosition + Mathf.Pow(t, 3) * controlPoints[3].localPosition;
    }

    public Vector2 GlobalBezier(float t)
    {
        return Mathf.Pow(1 - t, 3) * controlPoints[0].position + 3 * Mathf.Pow(1 - t, 2) * t * controlPoints[1].position + 3 * (1 - t) * Mathf.Pow(t, 2) * controlPoints[2].position + Mathf.Pow(t, 3) * controlPoints[3].position;
    }
}