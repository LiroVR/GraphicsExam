using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SphereLife : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        // Destroy the sphere after 5 seconds
        Destroy(gameObject, 5.0f);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
