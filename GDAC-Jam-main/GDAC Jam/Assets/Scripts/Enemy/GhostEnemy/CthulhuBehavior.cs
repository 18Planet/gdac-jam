using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CthulhuBehavior : EnemyBehavior
{
    [SerializeField]
    private AudioSource source;
    [SerializeField]
    private GameObject spawnEnemy;
    [SerializeField]
    private GameObject spawnPos;

    private bool aggro;

    int behaviorIndex;
    float timer = 0f;
    float[] behaviorDurations =
    {
        2f,
        6f, 
        3f,
    };


    private float angle = 0;

    public override void UpdateBehavior()
    {
        Vector2 dir = targetTransform.position - physicsBody.position;
        if(behaviorIndex == 0)
        {
            if (dir.magnitude > 0.5f && dir.magnitude < 15f)
                ChaseBehavior(dir);
            else
                inputDataOutput.MovementInput = Vector2.zero;
        }
        if(behaviorIndex == 1 && dir.magnitude < 15f)
        {
            angle += Time.deltaTime * 2f;
            Vector2 target = (Vector2)targetTransform.position + new Vector2(Mathf.Cos(angle), Mathf.Sin(angle)) * 2f;
            Vector2 circleDir = target - (Vector2)physicsBody.position;
            ChaseBehavior(circleDir);
        }
        if(behaviorIndex == 2)
        {
            SpawnBehavior();
            NextBehavior();
            if (behaviorIndex == 1)
                angle = -Mathf.Atan2(dir.y, dir.x);
        }

        timer -= Time.deltaTime;
        if(timer < 0f)
        {
            NextBehavior();
            if (behaviorIndex == 1)
                angle = -Mathf.Atan2(dir.y, dir.x);
        }

    }

    private void NextBehavior()
    {
        behaviorIndex = (behaviorIndex + 1) % behaviorDurations.Length;
        timer = behaviorDurations[behaviorIndex];
    }

    private void ChaseBehavior(Vector2 dir)
    {
        inputDataOutput.MovementInput = dir;
        //Debug.Log("Sounds");
        if(!aggro) StartCoroutine(Sounds());
    }

    private void SpawnBehavior()
    {
        for(int i = 0;i < 6;i++)
        {
            Vector2 pos = (Vector2)spawnPos.transform.position + Random.insideUnitCircle.normalized * 6f;
            Instantiate(spawnEnemy, pos, Quaternion.identity);
        }
    }

    public IEnumerator Sounds()
    {
        aggro = true;
        source.PlayOneShot(source.clip);
        yield return new WaitForSeconds(Random.Range(1f, 3f));
        StartCoroutine(Sounds());
    }
}
