shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float col = sin(TIME)/2.0+0.5;
	float col2 = sin(TIME+PI/3.0)/2.0+0.5;
	float col3 = sin(TIME+2.0*PI/3.0)/2.0+0.5;
	//float coler = sqrt(pow(abs(SCREEN_UV.x / sin(TIME)/2.0+0.5),2) + pow(abs(SCREEN_UV.y / cos(TIME)/2.0+0.5),2));

	float TS1 = sin(TIME/2.0+1.0);
	float TS2 = sin((TIME+PI/2.0)/2.0);
	float TS3 = sin(-TIME+2.0);
	float TS4 = sin(1.0-TIME/3.0);
	float TC1 = cos(TIME/2.0+2.0);
	float TC2 = cos(-TIME+1.0);
	float TC3 = cos((TIME+PI/2.0)/4.0);
	float TC4 = cos(TIME/3.0);

	float coler = 0.0;
	float size = 0.06;
	float margin = 0.2;
	size += margin;
	coler = (size-margin)/distance(UV, vec2((TS1/-2.0+0.5)*(1.0 - size * 2.0) + size,((TC1/2.0+0.5)*(1.0 - size * 2.0) + size)));
	float coler1 = 0.0;
	float size1 = 0.05;
	float margin1 = 0.2;
	size1 += margin1;
	coler1 = (size1-margin1)/distance(UV, vec2((TS2/-2.0+0.5)*(1.0 - size1 * 2.0) + size1,((TC2/2.0+0.5)*(1.0 - size1 * 2.0) + size1)));
	float coler2 = 0.0;
	float size2 = 0.03;
	float margin2 = 0.1;
	size2 += margin2;
	coler2 = (size2-margin2)/distance(UV, vec2((TS3/-2.0+0.5)*(1.0 - size2 * 2.0) + size2,((TC3/2.0+0.5)*(1.0 - size2 * 2.0) + size2)));
	float coler3 = 0.0;
	float size3 = 0.05;
	float margin3 = 0.1;
	size3 += margin3;
	coler3 = (size3-margin3)/distance(UV, vec2((TS4/-2.0+0.5)*(1.0 - size3 * 2.0) + size3,((TC4/2.0+0.5)*(1.0 - size3 * 2.0) + size3)));
	float glitchLen = 0.1;
	float Temp1 = mod(sin(TIME/2.0)/2.0,glitchLen);
	float Temp2 = mod(sin(TIME/2.0+2.0)/2.0,glitchLen);
	float glitch = min(max(abs(Temp1-mod(UV.x,glitchLen))*3000.0-1.0,0.0),10.0);
	float glitch2 = min(max(abs(Temp1-mod(UV.y,glitchLen))*3000.0-1.0,0.0),10.0);
	float glitch3 = min(max(abs(Temp2-mod(UV.x,glitchLen))*3000.0-1.0,0.0),10.0);
	float glitch4 = min(max(abs(Temp2-mod(UV.y,glitchLen))*3000.0-1.0,0.0),10.0);
	//glitch += abs(mod(TIME/2.0-0.2,1.0)-UV.x)*10000.0-1.0;
	//glitch += abs(mod(TIME/2.0-0.3,1.0)-UV.x)*10000.0-1.0;
	vec3 Norm = vec3(coler+glitch2/100.0,coler1+glitch/100.0+glitch4/100.0, coler2 + coler3+glitch3/100.0);
	//vec3 Norm = vec3(0.0,glitch, 0.0);
	Norm = Norm*8.0;
	vec3 Temp = Norm;
	Norm.x = min(Temp.x + 2.0- Temp.z - Temp.y/2.0, 1.0);
	Norm.y = min(Temp.y * 2.0 - Temp.z - Temp.x/2.0, 1.0);
	Norm.z = min(Temp.z / 10.0 + 5.0 - Temp.x - Temp.y, 1.0);
	Norm = Norm/(Norm.x+Norm.y+Norm.z);
	//COLOR = vec4(glitch,0.0,0.0,1.0);
	ALBEDO = vec3(((coler+coler1+coler2)*Norm.x*col)/2.0,((coler+coler1+coler2)*Norm.y*col2)/2.0,((coler+coler1+coler2)*Norm.z*col3)/2.0);
	ALBEDO = ALBEDO/(ALBEDO.x+ALBEDO.y+ALBEDO.z) * ALBEDO;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
