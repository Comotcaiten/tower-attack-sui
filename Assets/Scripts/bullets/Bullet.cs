using System.Collections;
using UnityEngine;

public class Bullets : MonoBehaviour
{
    public Defender ower;
    public Rigidbody2D rb;

    // Like (9, 5) mean object ca ben go max (9, 5) and min (-9, -5)
    private Vector2 rangeAreMove = new Vector2(20, 20);
    private bool isUse = true;

    void FixedUpdate()
    {
        rb.velocity = Vector3.left * 5f;
        CheckBounds();
    }

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
        yield return new WaitForSeconds(0.05f);

        Destroy(gameObject);
    } 

    void CheckBounds()
    {
        Vector3 pos = transform.position;

        if (Mathf.Abs(pos.x) > Mathf.Abs(rangeAreMove.x) ||
            Mathf.Abs(pos.y) > Mathf.Abs(rangeAreMove.y))
        {
            Destroy(gameObject);
        }
    }
}