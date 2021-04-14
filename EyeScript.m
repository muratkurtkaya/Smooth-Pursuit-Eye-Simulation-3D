clear all;
close all;
%% kutunun ilerleme hareketi, belli aralýklarla kutu ile gözün arasýndaki
% açý hesaplanýp göz döndürülecek.
fix_step_size=0.001;
t_finish_box = 10; % in secs
y_dist = 10; % box y vertical distance from eyes
box_time = linspace(0,t_finish_box,t_finish_box/fix_step_size+1);
box_time = transpose(box_time);
slow_time = 1;
box_start = +3;
box_end   = -3;

box_x_data     = linspace(box_start,box_end,t_finish_box/fix_step_size+1);
box_x_data     = transpose(box_x_data);
box_x_movement = timeseries(box_x_data,box_time);

box_y = timeseries(y_dist*ones(length(box_time),1),box_time);

fps = 200;
%insan gözünün saniyede 200 kare gördüðünü varsayarak ilerlicem.
%yani 1 saniyelik görüntüyü 200kareye bölerek aradaki açý farkýnýna denk
%düþen þiddeti uygulucam.

%kutu ile göz arasýnda y_dist,10, metre oldugunu varsayýyorum.
%gözün baþlangýç konumundaki açýlarý.
leftEyeStartDegree   = atand((-0.1-box_start)/y_dist);
rightEyeStartDegree  = atand((+0.1-box_start)/y_dist);

%% initialization for eye paremeters
%initial values for both left and right eyes, unit : [g * tension / degree]
Kse  = 1.8;
K    = 0.86;
B    = 0.018;
J    = 4.3 * 10e-5;
zero = 5e-3; %simulation delay,
theta_size = t_finish_box * fps; %hareket boyunca kaç kere theta deðiþtiðini tutuyor
%theta_size = (length(box_time)-1)/1;

%% left eye initialization
%baþlangýç durumundaki x1,x2,x3,v1 durumlarý.
LeftTheta1_init = leftEyeStartDegree;
LeftTheta1dot_init = 0 ;
LeftTheta2_init = 0 ;
LeftTheta3_init = 0 ;

LeftAgStepLog = zeros(1,theta_size);
LeftAgStepLog(1) = 16+0.8*leftEyeStartDegree; %should be different, think about it
LeftAntStepLog = zeros(1,theta_size);
LeftAntStepLog(1) = 16 - 0.06*leftEyeStartDegree; %%should be different, think about it
LeftAgInit = LeftAgStepLog(1);   % kaslardaki baþlangýc gerilimi 16N
LeftAntInit = LeftAntStepLog(1);

LeftDthetaValues=zeros(1,theta_size);
%left_dtheta_sum holds the all left_theta values over time
left_dtheta_sum=zeros(0);

%% right eye initialization
RightTheta1_init = rightEyeStartDegree;
RightTheta1dot_init = 0;
RightTheta2_init = 0;
RightTheta3_init = 0;

RightAgStepLog = zeros(1,theta_size);
RightAgStepLog(1) = 16  + 0.8*rightEyeStartDegree; %should be different, think about it
RightAntStepLog = zeros(1,theta_size);
RightAntStepLog(1) = 16 - 0.06*rightEyeStartDegree; %%should be different, think about it
RightAgInit  = RightAgStepLog(1);   % kaslardaki baþlangýc gerilimi 16N
RightAntInit = RightAntStepLog(1);

RightDthetaValues=zeros(1,theta_size);
%right_dtheta_sum holds the all left_theta values over time
right_dtheta_sum=zeros(0);

%% ############################ simulation ############################
for m =1:theta_size
    %AG ve ANT kaslarýnýn denge(0derecedeki) durumundaki gerilimleri.
    
    %theta deðiþimini tutan vektor ve zaman vektoru, simulasyon sonrasýnda, bunu göze
    %uyguluyoruz.
    box_len = length(box_x_data);
    % KONTROL ET
    if m>2 && m ~= theta_size+1
        LeftDthetaValues(m)  = atand((-0.1-box_x_data(m*round(box_len/theta_size)+1))/y_dist)-model.LeftTheta1.data(end);
        RightDthetaValues(m) = atand((+0.1-box_x_data(m*round(box_len/theta_size)+1))/y_dist)-model.RightTheta1.data(end);
    elseif m==theta_size+1
        LeftDthetaValues(m)  = atand((-0.1-box_x_data(end)/y_dist))-model.LeftTheta1.data(end);
        RightDthetaValues(m) = atand((+0.1-box_x_data(end)/y_dist))-model.RightTheta1.data(end);
    else
        LeftDthetaValues(m)  = atand((-0.1-box_x_data(m*round(box_len/theta_size)+1))/y_dist)-leftEyeStartDegree;
        RightDthetaValues(m) = atand((+0.1-box_x_data(m*round(box_len/theta_size)+1))/y_dist)-rightEyeStartDegree;
    end
    
    
    %feedError = 45; %feedback constant for error
    %dTheta = dTheta - theta_error /feedError;
    
    %% ############################ left eye simulation update ############################
    OldLeftTheta(m) =  LeftDthetaValues(m);
    LeftDthetaValues(m) = theta_rounder(LeftDthetaValues(m)); %rounds the dthetaValues(m) value
    switch LeftDthetaValues(m)
        case 0,    LeftPh=0;    LeftPW=1e-5;
        case 1e-1, LeftPh=17.6; LeftPW=10e-3;
        case 5e-1, LeftPh=20;   LeftPW=10e-3;
        case 1,    LeftPh=22;   LeftPW=11e-3;
        case 5,    LeftPh=53;   LeftPW=15e-3;
        case 10,   LeftPh=87;   LeftPW=20e-3;
        case 20,   LeftPh=124;  LeftPW=31e-3;
        case 30,   LeftPh=155;  LeftPW=40e-3;
    end
    
    % should add N_AG_Step_prev and N_ANT_Step_prev
    %AG
    LeftAgStepPrev      = LeftAgStepLog(m);
    LeftAgPulse         = LeftPh;
    LeftAgStep          = LeftAgStepPrev+0.8*LeftDthetaValues(m);
    LeftAgStepLog(m+1)  = LeftAgStep;
    LeftAgPW            = LeftPW;
    
    %ANT
    LeftAntStepPrev     = LeftAntStepLog(m);
    LeftAntPulse        = 0.5 + LeftAntStepPrev*exp(-LeftDthetaValues(m)/2.5);
    LeftAntStep         = LeftAntStepPrev - 0.06*LeftDthetaValues(m);
    LeftAntStepLog(m+1) = LeftAntStep;
    LeftAntPW           = LeftAgPW; + 6e-3; %Antagonist PW circumscribes Agonist PW by 3 ms on each side
    LeftTauAg_AC        = (13 - 0.1*LeftDthetaValues(m))*1e-3;
    
    
    
    %% ############################ right eye simulation update ############################
    OldRightTheta(m) = RightDthetaValues(m);
    RightDthetaValues(m) = theta_rounder(RightDthetaValues(m)); %rounds the dthetaValues(m) value
    switch RightDthetaValues(m)
        case 0,    RightPh=0;    RightPW=1e-5;
        case 1e-1, RightPh=17.6; RightPW=10e-3;
        case 5e-1, RightPh=20;   RightPW=10e-3;
        case 1,    RightPh=22;   RightPW=11e-3;
        case 5,    RightPh=53;   RightPW=15e-3;
        case 10,   RightPh=87;   RightPW=20e-3;
        case 20,   RightPh=124;  RightPW=31e-3;
        case 30,   RightPh=155;  RightPW=40e-3;
    end
    
    % should add N_AG_Step_prev and N_ANT_Step_prev
    %AG
    RightAgStepPrev      = RightAgStepLog(m);
    RightAgPulse         = RightPh;
    RightAgStep          = RightAgStepPrev+0.8*RightDthetaValues(m);
    RightAgStepLog(m+1)  = RightAgStep;
    RightAgPW            = RightPW;
    
    %ANT
    RightAntStepPrev     = RightAntStepLog(m);
    RightAntPulse        = 0.5 + RightAntStepPrev*exp(-RightDthetaValues(m)/2.5);
    RightAntStep         = RightAntStepPrev - 0.06*RightDthetaValues(m);
    RightAntStepLog(m+1) = RightAntStep;
    RightAntPW           = RightAgPW + 6e-3; %Antagonist PW circumscribes Agonist PW by 3 ms on each side
    RightTauAg_AC        = (13 - 0.1*RightDthetaValues(m))*1e-3;
    %
    
    
    %% ############################ simulation for both left and right eyes ############################
    %eye_model start and finish time
    %     t_start = (m-1)*t_finish_box/theta_size; %sim time for eye_moodel
    %     if m == theta_size + 1
    %         %kutu durduktan sonra son steady state gelmesi için 20ms ekledim.
    %         t_finish = (m+2)*t_finish_box/theta_size;
    %     else
    %         t_finish = m*t_finish_box/theta_size; %sim time for eye_model
    %     end
    
    t_start  = (m-1)*t_finish_box/theta_size;
    t_finish = m*t_finish_box/theta_size;
    model = sim('eye_model');
    
    
    
    %% ############################ Left Eye Parameter Update ############################
    % In this section, I update the parameters for next simulation's initialization
    left_dtheta_sum = vertcat(left_dtheta_sum,model.dThetaLeft);
    
    LeftTheta1         = model.LeftTheta1.data;
    LeftTheta1_init    = LeftTheta1(end);
    %   LeftEyeThetaRotate(m) = model.LeftTheta1;
    
    LeftTheta2         = model.LeftTheta2.data;
    LeftTheta2_init    = LeftTheta2(end);
    
    LeftTheta3        = model.LeftTheta3.data;
    LeftTheta3_init   = LeftTheta3(end);
    
    LeftTheta1dot      = model.LeftTheta1dot.data;
    LeftTheta1dot_init = LeftTheta1dot(end);
    
    LeftAgInit  =  LeftAgStepPrev;
    LeftAntInit =  LeftAntStepPrev;
    
    %% ############################ Right Eye Parameter Update ############################
    % In this section, I update the parameters for next simulation's initialization
    %dtheta_sum = vertcat(dtheta_sum,model.dtheta);
    right_dtheta_sum = vertcat(right_dtheta_sum,model.dThetaRight);
    
    %error at each eye movement
    
    
    RightTheta1         = model.RightTheta1.data;
    RightTheta1_init    = RightTheta1(end);
    %   RightEyeThetaRotate(m) = model.LeftTheta1;
    
    RightTheta2         = model.RightTheta2.data;
    RightTheta2_init    = RightTheta2(end);
    
    RightTheta3         = model.RightTheta3.data;
    RightTheta3_init    = RightTheta3(end);
    
    RightTheta1dot      = model.RightTheta1dot.data;
    RightTheta1dot_init = RightTheta1dot(end);
    
    RightAgInit         =  RightAgStepPrev;
    RightAntInit        =  RightAntStepPrev;


end

%% ############################## Simulation Results #########################
last_error_left  = left_dtheta_sum(end) - atand((-0.1-box_x_data(end))/y_dist) %%shows last error of the system
last_error_right = right_dtheta_sum(end) - atand((+0.1-box_x_data(end))/y_dist) %%shows last error of the system

%simulasyon boyunca geçen süre t:
t = linspace(0,t_finish,length(left_dtheta_sum));
% figure(1)
% subplot(2,1,1);
% box_left = atand((-0.1-box_x_data)/y_dist);
% plot(t,left_dtheta_sum);
% hold on;
% plot(box_time,box_left);
% subplot(2,1,2);
% box_right = atand((+0.1-box_x_data)/y_dist);
% hold on;
% plot(t,right_dtheta_sum);
% plot(box_right);
% figure(2);
% subplot(2,1,1);
% plot(t,last_error_left);
% subplot(2,1,2);
% plot(t,last_error_right);

%% ############################ 3D ANIMATION ############################
LeftVrTheta     =   timeseries(left_dtheta_sum,t);
RightVrTheta    =   timeseries(right_dtheta_sum,t);

box_x_new_data  =   linspace(box_end,box_end,(t_finish-t_finish_box)/fix_step_size);
box_x_new_data  =   transpose(box_x_new_data);
box_x_data      =   vertcat(box_x_data,box_x_new_data);

box_time        =   linspace(0,t_finish,t_finish/fix_step_size+1);
box_time        =   transpose(box_time);
box_time        =   box_time(1:length(box_x_data));
box_x_movement  =   timeseries(box_x_data,box_time);

t = linspace(0,t_finish,length(left_dtheta_sum));
figure(1)
subplot(2,1,1);
box_left = atand((-0.1-box_x_data)/y_dist);
plot(t,left_dtheta_sum);
hold on;
plot(box_time,box_left);
legend('left_dtheta','box_left');
subplot(2,1,2);
box_right = atand((+0.1-box_x_data)/y_dist);
plot(t,right_dtheta_sum);
hold on;
plot(box_time,box_right);
legend('right_dtheta','box_right');

sim('eye_animation');


