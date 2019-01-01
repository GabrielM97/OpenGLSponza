#version 330

struct Light
{
    vec3 position;
    float range;
    vec3 colour;
    vec3 direction;
    float field_of_view;
    mat4 projection_view_xform;
};

uniform float time_seconds;
uniform vec3 camera_position;
uniform Light light_source;
uniform sampler2D sampler_tex0;
uniform sampler2D sampler_tex1;
uniform sampler2D sampler_tex2;


in vec3 p;
in vec3 n;

out vec4 fragment_colour;
vec3 l;
float random(vec2 n)
{
  return 0.5 + 0.5 * 
     fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
}

Light createLight (vec3 pos, float range, vec3 colour)
{
    Light new_light;
    new_light.position = pos;
    new_light.range = range;
    new_light.colour = colour;
    return new_light;
}

float calc_diffuse_lighting(Light light)
{
    l = normalize(light.position - p);
   
    
    return  max(dot(l, n), 0.0);
}

float calc_spec_lighting(Light light)
{
    
     l = normalize(light.position - p);
    vec3 r = reflect(l, n);
    vec3 rv = normalize(p);
   

    return pow(max(dot(r, rv), 0.0), 16);
}

void main(void)
{
   
    const int numberOfLights = 3;
    Light lights[numberOfLights];
    float allLights = 0;
    vec3 intesity_colour_of_incoming_light;

    lights[0] = light_source;
    vec3 pointLight = vec3(1.0, 0.8, 0.6);
    lights[0].colour = pointLight;

    
    vec3 e_pos = vec3(260,8,90);
    float x = -cos(time_seconds) * e_pos.x/2 ;
    float y = -cos(time_seconds) * e_pos.y/2 ;
    float z = -sin(time_seconds) * e_pos.z/2;
    Light new_light = createLight(vec3(x,y,z), 50, vec3(1,1,0));
    lights[1] = new_light;


    lights[2] = createLight(vec3(-cos(time_seconds*1.5) * 240/2 ,
                                 60,
                                 sin(time_seconds*1.5) * 90/2), 60, vec3(1,0,1));
    
  

    vec3 intesity_colour_of_ambient_light = vec3(0.1 , 0.1, 0.1);
    //vec3 reflected_light = pointLight * diffuse_intesity;
    vec3 ambient_colour_material = vec3(0.85, 0.80, 0.66);
    vec3 ambient_diffuse_material = vec3(0.85, 0.80, 0.66);


    float vary_x = 240;
    for(int lightNumber = 3; lightNumber < numberOfLights; lightNumber ++)
    {
        
        lights[lightNumber] = createLight(vec3(cos(time_seconds) * vary_x/2 ,70,
                                  -sin(time_seconds) * 50/2), 60, vec3(1*cos(time_seconds*lightNumber), 1*sin(time_seconds*lightNumber), 1*-sin(time_seconds*lightNumber)));
        
        vary_x -= 50;
    }

    for(int lightIndex = 0; lightIndex < numberOfLights-1; lightIndex ++)
    {
        float lightDistance = distance(p, lights[lightIndex+1].position);
        float attenuation = 1.0- smoothstep(0.5, lights[lightIndex+1].range, lightDistance);
        
        intesity_colour_of_incoming_light +=  lights[lightIndex+1].colour * (( ambient_diffuse_material *  calc_diffuse_lighting(lights[lightIndex+1]) 
                                        +  2 * calc_spec_lighting(lights[lightIndex+1])) * attenuation) ;

        if(dot(-(normalize(lights[0].position - p)), lights[0].direction) < cos(0.5 * lights[0].field_of_view))
        {
            intesity_colour_of_incoming_light +=  lights[0].colour * (( ambient_diffuse_material *  calc_diffuse_lighting(lights[0]) 
                                                +  2 * calc_spec_lighting(lights[0])) ) ;
        }else
            intesity_colour_of_incoming_light += (intesity_colour_of_ambient_light * calc_diffuse_lighting(light_source)  );
    }
    
    
    vec3 I;
    I = (intesity_colour_of_ambient_light*ambient_colour_material)+intesity_colour_of_incoming_light ;
    
    fragment_colour = vec4(I, 1.0);
    
    
}
