using UnityEngine;

public class Sensor : MonoBehaviour
{
    private bool isDetect = false;
    public bool IsDetect => isDetect;

    public Monster MonsterUnit {get; private set;}

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.CompareTag(TagConfigs.MonsterTag))
        {
            isDetect = true;
            MonsterUnit = collision.gameObject.GetComponent<Monster>();
        }
    }

    void OnTriggerExit2D(Collider2D collision)
    {
        if (collision.gameObject.CompareTag(TagConfigs.MonsterTag))
        {
            isDetect = false;
            MonsterUnit = null;
        }
    }
}