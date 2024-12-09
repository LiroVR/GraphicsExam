using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerScript : MonoBehaviour
{
    private Animator animator;
    private Vector2 moveVector, rotate;
    public float speed = 5f, sensitivity = 5f;
    [SerializeField, Range(0, 180)] private float viewAngleClamp = 40f;
    [SerializeField] private Transform camFollowTarget;
    private Rigidbody rb;
    private PlayerControls pControls;
    // Start is called before the first frame update
    void Start()
    {
        pControls = new PlayerControls();
        animator = GetComponent<Animator>();
        rb = GetComponent<Rigidbody>();
        pControls.Enable();
    }

    public void SetLook(Vector2 direction)
    {
        rotate = direction;
        transform.rotation *= Quaternion.AngleAxis(direction.x * sensitivity, Vector3.up);
        camFollowTarget.rotation *= Quaternion.AngleAxis(direction.y * -sensitivity, Vector3.right);
        camFollowTarget.rotation *= Quaternion.AngleAxis(direction.x * -sensitivity, Vector3.up);

        Vector3 angles = camFollowTarget.eulerAngles;
        float anglesX = angles.x;
        if (anglesX > 180 && anglesX < 360-viewAngleClamp)
        {
            anglesX = 360-viewAngleClamp; //Used to limit the angle/amount of rotation to the clamp
        }
        else if (anglesX < 180 && anglesX > viewAngleClamp)
        {
            anglesX = viewAngleClamp;
        }

        camFollowTarget.localEulerAngles = new Vector3(anglesX, 0, 0); //Sets the rotation of the camera to limit rotation
    }

    // Update is called once per frame
    void Update()
    {
        moveVector = pControls.Walking.Movement.ReadValue<Vector2>(); //Gets the movement data from the Input system
        transform.Translate(Time.deltaTime * speed * moveVector.y * Vector3.forward); //Converts the data to be used in 3D space (changing y for z)
        transform.Translate(Time.deltaTime * speed * moveVector.x * Vector3.right); //Same as above, but responsible for x axis
        SetLook(pControls.Walking.Look.ReadValue<Vector2>()); //Reading the 'Look' from the input system
        animator.SetFloat("VelocityX", speed*moveVector.x); //Controls animator values to run the locomotion animations
        animator.SetFloat("VelocityZ", speed*moveVector.y);
        /*
        if (pControls.Walking.Scan.triggered)
        {
            animator.SetBool("Scan", true);
        }
        else
        {
            animator.SetBool("Scan", false);
        }
        */
    }
}
