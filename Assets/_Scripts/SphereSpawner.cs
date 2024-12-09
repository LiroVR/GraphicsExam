using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SphereSpawner : MonoBehaviour
{
    [SerializeField] private GameObject spherePrefab;
    [SerializeField] private GameHandler gameHandler;
    [SerializeField] private float shootForce = 1.0f, sphereSize = 1.0f, sphereMass = 1.0f;

    // Update is called once per frame
    void Update()
    {
        // Spawn a sphere when the user presses the space key, that shoots forward like a bullet
        if (Input.GetKeyDown(KeyCode.Space) && gameHandler.barPower >= 0.1f)
        {
            GameObject sphere = Instantiate(spherePrefab, transform.position, Quaternion.identity);
            Rigidbody rb = sphere.GetComponent<Rigidbody>();
            sphere.transform.localScale = new Vector3(sphereSize, sphereSize, sphereSize);
            rb.mass = sphereMass;
            rb.AddForce(transform.forward * 1000*shootForce, ForceMode.Impulse);
            gameHandler.barPower -= 0.1f;
        }
    }
}
