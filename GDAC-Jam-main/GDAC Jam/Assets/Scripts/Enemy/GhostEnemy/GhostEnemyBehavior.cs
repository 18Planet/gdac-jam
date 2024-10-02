using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GhostEnemyBehavior : EnemyBehavior
{
    [SerializeField]
    private AudioSource source;

    private bool aggro;

    int behaviorIndex;
    float timer = 0f;
    float[] behaviorDurations =
    {
        1.5f,
        4f
    };


    private float angle = 0;
    private float rotateDir = 1;

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
            angle += rotateDir * Time.deltaTime * 2f;
            Vector2 target = (Vector2)targetTransform.position + new Vector2(Mathf.Cos(angle), Mathf.Sin(angle)) * 3.5f;
            Vector2 circleDir = target - (Vector2)physicsBody.position;
            ChaseBehavior(circleDir);
        }


        timer -= Time.deltaTime;
        if(timer < 0f)
        {
            behaviorIndex = (behaviorIndex + 1) % behaviorDurations.Length;
            timer = behaviorDurations[behaviorIndex] + Random.Range(-1f, 1f);
            if(behaviorIndex == 1)
                angle = -Mathf.Atan2(dir.y, dir.x);
            rotateDir = Mathf.Sign(Random.Range(-1f, 1f));
        }

    }

    private void ChaseBehavior(Vector2 dir)
    {
        inputDataOutput.MovementInput = dir;
        //Debug.Log("Sounds");
        if(!aggro) StartCoroutine(Sounds());
    }

    public IEnumerator Sounds()
    {
        aggro = true;
        source.PlayOneShot(source.clip);
        yield return new WaitForSeconds(Random.Range(1f, 3f));
        StartCoroutine(Sounds());
    }
}
