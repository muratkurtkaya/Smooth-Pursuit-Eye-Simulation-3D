clear all;
close all;
%% simulasyon derleme s�resi �ok uzun s�rd��� i�in �nceden �al��t�r�p workspaceleri kaydettim;
slow_time = 1; %g�z animasyonunun s�resini ayarlamak i�in, art�r�nca animasyon yava�l�yor.
starting_point = 0; %araban�n x eksenindeki ba�lang�� noktas�.
box_time = input('enter the car time: 6 or 10: ') %%araban�n ne kadar s�rede hareketini tamamlad���
while box_time ~=3 && box_time~=6 && box_time~=10
    disp('please enter valid box_time');
    box_time = input('enter the car time: 6 or 10: ')
end



if box_time == 6
    while starting_point ~= 0.5 && starting_point ~= 3
        starting_point = input('Enter starting point: 0.3 or 3 ');
    end  
    
    if starting_point == 0.5
        load('6_0_5_4');
    else
        load('6_3_3');
    end
elseif box_time ==10
    load('10_3_3');
end

figure(1)
subplot(2,1,1);
box_left = atand((-0.1-box_x_data)/y_dist);
plot(t,left_dtheta_sum);
hold on;
plot(box_time,box_left);
xlabel('time: in secs'), ylabel('LeftEyeDegree: in degrees');
title('LeftEye Degree vs Targeted Degree');
legend('left_dtheta','box_left');
subplot(2,1,2);
box_right = atand((+0.1-box_x_data)/y_dist);
plot(t,right_dtheta_sum);
xlabel('time: in secs'), ylabel('RightEyeDegree: in degrees');
title('RightEye Degree vs Targeted Degree');
hold on;
plot(box_time,box_right);
legend('right_dtheta','box_right');

last_error_left
last_error_right

sim('eye_animation')

