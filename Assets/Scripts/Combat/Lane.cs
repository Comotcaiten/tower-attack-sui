// using System.Collections.Generic;
// using UnityEngine;
// public class Lane : MonoBehaviour
// {
//     public List<Monster> monstersInLane = new();
//     public Defender defender;

//     void Update()
//     {
//         HandleCombat();
//     }

//     void HandleCombat()
//     {
//         if (monstersInLane.Count == 0) return;

//         Monster frontMonster = monstersInLane[0];
//         defender.Attack(frontMonster);
//         frontMonster.Attack(defender);
//     }
// }
