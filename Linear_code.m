clc;clear all;close all;
%%%%%%%%���ɳ�ʼ����%%%%%%%
SignNum = 100; %��Ϣ����
genmat=[1 0 0 0 1 1 1;0 1 0 0 1 1 0;0 0 1 0 1 0 1;0 0 0 1 0 1 1];
Length = SignNum ; %ԭʼ�����г���
OrigiSeq=(sign(randn(1,SignNum))+1)/2; %����ԭʼ��0��1��Ϣ����
%%%%%%%%hamming����%%%%%
ConCode=encode(OrigiSeq,7,4,'linear',genmat); %���Է�������������
%%%%%BPSK����%%%%%%%%
BPSKCode =pskmod(ConCode,2);
%%%%%%%���������%%%%%%%%%%%%
EbN0 =-6:6; %EbN0-dB
snr=10.^(EbN0./10); %ת��Ϊ���������


%%%%%%%%%%%%%�����ѭ������ͳ��������%%%%%%%%%%%%
for k = 1:length(EbN0)
    for b=1:100;
        %%%%%%%%%%%%%%���Ը�˹�������ŵ�%%%%%%%%%%%
        RecCode = awgn(BPSKCode,EbN0(k),'measured');
        %%%%%%%%%%%%%%BPSK���%%%%%%%%%%%%%%%
        
        % BPSKdecode = BPSKDecode(RecCode, Length*7/4); ? %BPSK���
        
        BPSKdecode=pskdemod(RecCode,2); %%%%%%%�����ʽ�ӿ���ֱ�����Դ�pskdemod����������������õ��ú���%%%%%%%%%
        
        %% ������
        
        OrigiSeq2 =reshape(OrigiSeq,(SignNum)/4,4); %%ԭʼbit��Ϣ��װ�� 25*4����
        SignNums=length(BPSKdecode);
        BPSKdecode1=reshape((BPSKdecode)',7,(SignNums)/7); %%��װ�� 25*7����
        BPSKdecode1=(BPSKdecode1)';
        
        
        BPSKdecode=jiucuo(OrigiSeq2,BPSKdecode1); %%%%%���þ���
        
        %%%% ?a:ע��reshape������ʹ�ã����ж�ȡ�����д洢
        %%%% ?b:BPSKdecode=jiucuo(OrigiSeq2,BPSKdecode1)����ʵֻ��һ������BPSKdecode1����
        
        
        
        [g,h]=size(BPSKdecode); % g=1,h=175
        %%%%%%%%%%%%%% ? ? ? ?linear������%%%%%%%%%%%%%%
        Decoder=decode(BPSKdecode,7,4,'linear',genmat);
        [m,n]=size(Decoder); % m=1,n=100
        
        
        %%%%%%%ͳ��������%%%%%%%%
        
        [o,p]=size(OrigiSeq); %%% ?o=1,p=100
        error(b) = sum(abs(Decoder-OrigiSeq))/Length;
    end
    %%%%%%%%%%%%%%����ƽ��������%%%%%%%%%%%%%
    errorout(k)=mean(error);
    OrigiSeq1=OrigiSeq(1:20);%��ȡǰ20��������
    Decoder1=Decoder(1:20);
%     figure
    t=1:20;
    subplot(211);stairs(t,OrigiSeq1,'r');axis([1 20 -0.5 1.5]);title(['����ǰ����',num2str(EbN0(k)),'dB']);
    subplot(212);stairs(t,Decoder1,'b');axis([1 20 -0.5 1.5]);title(['���������',num2str(EbN0(k)),'dB']);
    F = getframe;
    movie(F,1,0.5)
end
close all;


%%%%%%%%%%%%%��������������%%%%%%%%%%%%%
ber_theory=0.5*erfc(sqrt(snr)); %���������������


ber_theory;

%%%%%%%%%%%%%��������������%%%%%%%%%%%%%%
figure; 
semilogy (EbN0,errorout,'b*-',EbN0,ber_theory,'rd-');
hold on
xlabel('Eb/N0(dB)');
ylabel('�������');
legend('�� linear code','����ֵ');
title('BPSK+linear�����������');
grid on; %%%%���������






