clc;clear all;close all;
%%%%%%%%��Դ����%%%%%%%
%ת�Ҷ�ͼ
%image=imread('1IMG_5839.JPG');
image=imread('test1.jpg');
image=rgb2gray(image);
figure(1);
imshow(image);
%��Դ���롪������������
I2=image;
[m,n]=size(I2);
J=reshape(I2,m*n,1);
first_all=length(J);
N=numel(I2);
Pr=imhist(I2)/N;
sym=0:255;
figure(2)
stem(J,'filled');
title(['����������ǰ����']);

for i=1:256
    if(Pr(i)==0)
        sym(i)=256;
    end;
end;
Pr=Pr(find(Pr~=0));
H=sum(-Pr.*log2(Pr)) %ԭͼ��Ϣ��
sym=sym(find(sym~=256));
r1=zeros(length(Pr),1);
for i=1:length(Pr)
    r1(i)=Pr(i)*8;
end;
R1=sum(r1) %ԭƽ���볤
n1=H/R1  %ԭ����Ч��
dict=huffmandict(sym,Pr);
hcode=huffmanenco(J,dict); %����
 
figure(3)
stairs(hcode,'b');
axis([1 50 -0.5 1.5]);
title(['���������']);
%z1=huffmandeco(hcode,dict); %����
%I1=reshape(z1,m,n);
%figure(2);
%imshow(I1,[]);
r2=zeros(length(Pr),1);
for i=1:length(Pr)
    r2(i)=Pr(i)*size(cell2mat(dict(i,2)),2);
end;
R2=sum(r2)  %��ƽ���볤
n2=H/R2   %�ֱ���Ч��
C=R1/R2   %ѹ����
all=length(hcode);
%��0
lost=4-rem(length(hcode),4);
for i=1:lost
    hcode(all+i,1)=0;
end
%%%%%%%%�ŵ�����%%%%%%%
%�ŵ����롪����7��4��������
%�����롪������һλ����

genmat=[1 0 0 0 1 1 1;0 1 0 0 1 1 0;0 0 1 0 1 0 1;0 0 0 1 0 1 1];%��7��4���ල����
ConCode=encode(hcode,7,4,'hamming');%���������
figure(4)
stairs(ConCode,'b');
axis([1 50 -0.5 1.5]);
title(['74�����������']);
%stem(ConCode,'filled');
%axis([0  20  0  2]);


%%%%%%%%����%%%%%%%
%QPSK 2kHz����
fc=2e3;
%QPSK transmitter
data=length(ConCode)  ;   %������Ϊ5MHZ     %ԭ�����
rand_data=ConCode;
for  i=1:data
    if rand_data(i)>=0.5
        rand_data(i)=1;
    else
        rand_data(i)=0;
    end
end
%seriel to parallel        %ͬʱ��������תΪ˫������
for  i=1:data
    if rem(i,2)==1
        if  rand_data(i)==1
            I(i)=1;
            I(i+1)=1;
        else
            I(i)=-1;
            I(i+1)=-1;
        end
    else
        if rand_data(i)==1
            Q(i-1)=1;
            Q(i)=1;
        else
            Q(i-1)=-1;
            Q(i)=-1;
        end
    end
end
% zero insertion   ���˹��̳�Ϊ���Ρ����ε���˼����ʵ������Ϣ�����ε�ת�����Ա㷢�䣬�������Ӧ�����ڻ�������֮��
zero=5;         %sampling  rate  25M HZ  ,�����ˣ�zeroΪ�������ʡ������� ������fs/�����ʡ�
for  i=1:zero*data     % ��������Ŀ=��������*ԭ����Ŀ
    if rem(i,zero)==1
        Izero(i)=I(fix((i-1)/zero)+1);
        Qzero(i)=Q(fix((i-1)/zero)+1);
    else
        Izero(i)=0;
        Qzero(i)=0;
    end
end
%pulse shape filter�� ���ţ������е�ͨ�˲�����Ϊ ���Ŵ������ʵ����󣬻��������Ƶ�׽����
%������˲������������˲������е�ͨ�˲����������Ƶ��ʱ����ܻ�������ѡ�
%ƽ�����������˲���
% psf=rcosfir(rf,n_t,rate,fs,'sqrt')   rate:�������ʣ�rf:�������ӣ�n_t:�˲���������fs:������
%���ڵ��ƻ���֮ǰ�����ڽ�������֮���������͹���������������������ISI����䴮�ţ�
  
NT=50;
N=2*zero*NT;    % =500
fs=25e6;
rf=0.1;
psf=rcosfir(rf,NT,zero,fs,'sqrt');% psf��СΪ500
Ipulse=conv(Izero,psf);
Qpulse=conv(Qzero,psf);
%Ϊʲô�����źŴ���ҲҪ�������������˲���
%�𣺹������������źŴ��������Ե�ͨ�˲�����Ҫ����Խϵͣ���������������˲���ʱ���˲�����Ҫ�ܶ��ͣ�ָ�����ϸ�
%�����˲��������Ǳ�֤�����㲻ʧ�档���û���������ź��ھ��������ŵ�����ͼ�Ų�����ISI�ǳ����ء������˲���λ���ڻ�������֮��
%��Ϊ�������˲����źŵ���Ϣ�Ѿ�������ʧ����Ҳ��Ϊ����ISI�����Ĵ��ۡ����仰˵�������˲���λ�����ز�����֮ǰ���������ز����ơ�
%���������Ͷˣ���ֵ��������-����-�˲���LPF)-����Ƶ(�ز�����)-�������������նˣ��˱���-��ͨ-��ʱ��ȡ-�о���
SNR=60;%�����
%modulation
for i=1:zero*data+N   %��������Ŀ�ı� ����Ϊ�����Ե�ʣ�
    t(i)=(i-1)/(fs);  %������Ϊ������Ƶ�������ʴ�С��ȣ���������Ƶfc���Թ�������=�����ʡ�
    Imod(i)=Ipulse(i)*awgn(sqrt(2)*cos(2*pi*fc*t(i)),SNR);
    Qmod(i)=Qpulse(i)*awgn((-sqrt(2)*sin(2*pi*fc*t(i))),SNR);
end
sum=Imod+Qmod;
%QPSK  receiver
%demodulation
   for i=1:zero*data+N
       Idem(i)=sum(i)*awgn(sqrt(2)*cos(2*pi*fc*t(i)),SNR);
       Qdem(i)=sum(i)*awgn((-sqrt(2)*sin(2*pi*fc*t(i))),SNR);
   end
   %matched  filter
   mtf=rcosfir(rf,NT,zero,fs,'sqrt');
   Imat=conv(Idem,mtf);
   Qmat=conv(Qdem,mtf);
   %data selection
   for  i=1:zero*data
       Isel(i)=Imat(i+N);
       Qsel(i)=Qmat(i+N);
   end
   %sampler        %��ȡ��Ԫ  
   for i=1:data
       Isam(i)=Isel((i-1)*zero+1);
       Qsam(i)=Qsel((i-1)*zero+1);
   end
   %decision  threshold
   threshold=0.2;
   for  i=1:data
       if Isam(i)>=threshold
           Ifinal(i)=1;
       else
           Ifinal(i)=-1;
       end
       if Qsam(i)>=threshold
           Qfinal(i)=1;
       else
           Qfinal(i)=-1;
       end
   end
   %parallel to serial
   for i=1:data
       if rem (i,2)==1
           if Ifinal(i)==1
               final(i)=1;
           else
               final(i)=0;
           end
       else
           if  Qfinal(i)==1
               final(i)=1;
           else
               final(i)=0;
           end
       end
   end
   % ��ͼ
   figure(5)
   plot(20*log(abs(fft(rand_data))));
   axis([0  data  -40  100]);
   grid on;
   title('spectrum  of input binary data');
   figure(6)
   subplot(221);
   plot(20*log(abs(fft(I))));
   axis([0 data -40 140]);
   grid  on;
   title('spectrum of I-channel data');
   subplot(222);
   plot(20*log(abs(fft(Q))));
   axis([0  data   -40  140]);
   grid  on;
   title('spectrum of Q-channel data');
   subplot(223);
   plot(20*log(abs(fft(Izero))));
   axis([0 zero*data  -20  140]);
   grid  on;
   title('spectrum of I-channel after zero insertion');
   subplot(224);
   plot(20*log(abs(fft(Qzero))));
   axis([0  zero*data   -20 140]);
   grid  on;
   title('spectrum of Q-channel after zero insertion');
   figure(7);
   subplot(221);
   plot(psf);
   axis([10    300     -0.2    0.6]);
   title('time domain response of pulse shaping filter');
   grid  on;
   subplot(222);
   plot(20*log(abs(fft(psf))));
   axis([0  N   -400 400]);
   grid on;
   title('transfer  function  of pulse  shaping filter');
   subplot(223);
   plot(20*log(abs(fft(Ipulse))));
   axis([0  zero*data+N  -400 400]);
   grid on;
   title('spectrum of I-channel after  impulse shaping filter');
   subplot(224);
   plot(20*log(abs(fft(Qpulse))));
   axis([0  zero*data+N -250  150]);
   grid  on;
   title('spectrum of Q-channel  after pluse shaping  filter');
   figure(8)
   subplot(211);
   plot(20*log(abs(fft(Imod))));
   axis([0  zero*data+N  -250 150]);
   grid  on ;
   title('spectrum of I-channel  after modulation');
   subplot(212);
   plot(20*log(abs(fft(Qmod))));
   axis([0  zero*data+N  -250 150]);
   grid  on;
   title('spectrum  of  Q-channel after modulation');
   figure(9)
   subplot(221);
   plot(20*log(abs(fft(Idem))));
   axis([0 zero*data  -200  150]);
   grid on;
   title('spectrum  of I-channel after  demodulation');
   subplot(222);
   plot(20*log(abs(fft(Qdem))));
   axis([0  zero*data+N  -200  150 ]);
   grid  on;
   title('spectrum of Q-channel after demodulation');
   subplot(223);
   plot(20*log(abs(fft(Imat))));
   axis([0  zero*data  -400  200]);
   grid  on;
   title('spectrum  of I-channel  after  matched filter');
   subplot(224);
   plot(20*log(abs(fft(Qmat))));
   axis([0  zero*data  -400  200]);
   grid  on;
   title('spectrum of  Q-channel after matched filter');
   figure(10)
   subplot(221);
   plot(20*log(abs(fft(Isam))));
   axis([0 data  -40  150]);
   grid  on;
   title('spectrum of I-channel after sampler');
   subplot(222);
   plot(20*log(abs(fft(Qsam))));
   axis([0  data -40  150 ]);
   grid  on;
   title('spectrum of Q-channel after  sampler');
   subplot(223);
   plot(20*log(abs(fft(Ifinal))));
   axis([0 data  -40  150]);
   grid on;
   title('spectrum of  I-channel after  decision threshold');
   subplot(224);
   plot(20*log(abs(fft(Qfinal))));
   axis([0 data  -40  150]);
   grid on;
   title('spectrum of  Q-channel after  decision threshold');
   figure(11)
   plot(Isel,Qsel);
   axis([-1.6 1.6  -1.6  1.6]);
   grid  on;
   title('constellation  of  matched  filter  output');
   figure(12)
   plot(Isam,Qsam,'X');
   axis([-1.2  1.2   -1.2  1.2]);
   grid on;
   title('constellation  of  sampler');
   figure(13)
   plot(20*log(abs(fft(final))));
   axis([0  data  0  100]);
   grid  on;
   title('aspectrum  of  final  received  binary  data');

   figure(14)
   stairs(final,'b');
   axis([1 50 -0.5 1.5]);
   title(['���������']);
   %stem(final,'filled');
   %axis([0  30  0  2]);
   %%%%%���������%%%%%%
   Decoder=decode(final,7,4,'hamming');
   for i=1:all
       Decoder1(1,i)=Decoder(1,i);
   end
   
   figure(15)
   stairs(Decoder1,'b');
   axis([1 50 -0.5 1.5]);
   title(['��������������']);
   %stem(Decoder1,'filled');
   %axis([0  30  0  2]);

   %%%%%����������%%%%%%%
   final_1=huffmandeco(Decoder1,dict); %����
     now_all=length(final_1);
   for i=now_all:first_all
    final_1(1,i)=0;
   end
   for i=1:first_all
       final_2(1,i)=final_1(1,i);
   end
   
   figure(16)
   stem(final_2,'filled');
   title(['��������']);
   
final=(final)';
Pe=num2str(symerr(ConCode,final)/length(hcode))
   final_2=(final_2)';
   finally=reshape(final_2,m,n);
   figure(11);
   imshow(finally,[]);
rongliang = 2000*log2(1+SNR)
