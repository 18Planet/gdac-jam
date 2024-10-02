using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RoomSpawner : MonoBehaviour
{
    public int openingDirection;

    //Rooms
    private RoomTemplates templates;
    private int rand;
    private bool spawned = false;


    // Start is called before the first frame update
    void Start()
    {
      templates = FindObjectOfType<RoomTemplates>();
      if (templates.maxRooms <= 0) {
        spawned = true;
      } else {
        templates.maxRooms -= 1;
      }

      Invoke("Spawn", 0f);
    }

    // Update is called once per frame
    void Spawn()
    {
        if(spawned == false) {

            if (openingDirection == 1) {
              //BOTTOM
              rand = Random.Range(0, templates.bottomRooms.Length);
              Instantiate(templates.bottomRooms[rand], transform.position, templates.bottomRooms[rand].transform.rotation);
            } else if (openingDirection == 2) {
              //TOP
              rand = Random.Range(0, templates.topRooms.Length);
              Instantiate(templates.topRooms[rand], transform.position, templates.topRooms[rand].transform.rotation);
            } else if (openingDirection == 3) {
              //LEFT
              rand = Random.Range(0, templates.leftRooms.Length);
              Instantiate(templates.leftRooms[rand], transform.position, templates.leftRooms[rand].transform.rotation);
            } else if (openingDirection == 4) {
              //RIGHT
              rand = Random.Range(0, templates.rightRooms.Length);
              Instantiate(templates.rightRooms[rand], transform.position, templates.rightRooms[rand].transform.rotation);
            }

            spawned = true;
          }
    }

    void OnTriggerEnter(Collider other) {
      if(other.CompareTag("SpawnPoint")) {
        Destroy(gameObject);
      }
    }
}
