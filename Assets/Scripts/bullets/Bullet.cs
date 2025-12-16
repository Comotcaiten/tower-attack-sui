using System.Collections;
using UnityEngine;

public class Bullets : MonoBehaviour
{
    public Defender ower;
    public Rigidbody2D rb;

    private bool isUse = true;
    
    void OnTriggerEnter2D(Collider2D collision)
    {
        Debug.Log(collision.name);

        if (collision.gameObject.CompareTag(TagConfigs.MonsterTag) && isUse)
        {
            isUse = false;
            collision.gameObject.GetComponent<Monster>()!.TakeDamage(ower ? ower.attack : 1f);
            StartCoroutine(DestroyAfter());
        }
    }

    IEnumerator DestroyAfter() {
        yield return new WaitForSeconds(0.15f);

        Destroy(gameObject);
    }   
}