using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameHandler : MonoBehaviour
{
    public float barPower = 1;
    [SerializeField] private Animator barAnim;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //Bar power replenishes back to one over time
        if (barPower < 1)
        {
            barPower += Time.deltaTime * 0.1f;
        }
        else
        {
            barPower = 1;
        }
        //Set the value of the barPower to the animator
        barAnim.SetFloat("BarPower", barPower);
    }
}
