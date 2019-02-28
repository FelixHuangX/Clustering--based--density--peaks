function [C,cl] = cluster_density_image(J)
%C�д�ž������ĵ�ֵ
%cl���ÿһ��������
%�������ݣ�����������
[m, n, p] = size(J);
data = reshape(double(J), m*n, p);
dist = pdist2(data,data);

%����ض����dc
percent = 2.0;
N = size(dist,1);
position = round((N*(N-1)/2)*percent/100);
%��ȡdist���������󣬶Խ��߾�Ϊ0
tri_dist = triu(dist,1);
s_dist = sort(tri_dist(tri_dist~=0));
dc = s_dist(position);
%����ضϾ���
fprintf('Computing Rho with gaussian kernel of radius: %12.6f\n', dc);

%����ֲ��ܶȣ����ø�˹�ˣ�
rho = sum(exp(-(dist./dc).^2),2);
%�����о����е����ֵ
max_dist=max(max(dist));
%�� rho ���������У�ordrho���ԭ��rho_sorted��Ž����rho
[rho_sorted,ordrho]=sort(rho,'descend');

% ���� rho ֵ�������ݵ�
delta(ordrho(1))=-1;
%���ľֲ���ֵ�ĵ㣬nneighΪ0
nneigh(ordrho(1))=0;
% ���� delta �� nneigh ����
for k=2:N
   delta(ordrho(k))=max_dist;
   for p=1:k-1
     if(dist(ordrho(k),ordrho(p))<delta(ordrho(k)))
        delta(ordrho(k))=dist(ordrho(k),ordrho(p));
        nneigh(ordrho(k))=ordrho(p);    % ��¼���оֲ���ֵ��ordrho(k)��ĵ��У���������ĵ�ı��  
     end
   end
end
% ���� rho ֵ������ݵ�� delta ֵ
delta(ordrho(1))=max(delta(:));

%������ͼ������ rho �� delta ����һ����ν�ġ�����ͼ��
disp('Generated file:DECISION GRAPH')
figure
subplot(1,2,1)
plot(rho(:),delta(:),'o','MarkerSize',5,'MarkerFaceColor','b','MarkerEdgeColor','r');
title ('Decision Graph','FontSize',15.0)
xlabel ('\rho')
ylabel ('\delta')

%����gammaֵ
for i=1:N
  gamma(i)=rho(i)*delta(i);
end
[gamma_sorted,ordgamma]=sort(gamma,'descend');
subplot(1,2,2)
plot(gamma_sorted(:),'o','MarkerSize',5,'MarkerFaceColor','b','MarkerEdgeColor','r');
title ('Gamma Graph','FontSize',15.0)

%������ͣ������һ������ѡȡ���������q������ִ�����������
q = input('q=');

% ��ʼ�� cluster ����
NCLUST=0;
%cl(i)=j ��ʾ�� i �����ݵ�����ڵ� j �� cluster
for b=1:N
  cl(b)=-1;
end 
% ͳ�����ݵ㣨���������ģ��ĸ���
C = zeros(q-1,3);
for n=1:N
  if gamma(n) > gamma_sorted(q)
     NCLUST=NCLUST+1;
     cl(n)=NCLUST; % �� n �����ݵ��ǵ� NCLUST��ľ�������
     C(NCLUST,:) = data(n,:);
     icl(NCLUST)=n;%��ӳ��,�� NCLUST �� cluster ������Ϊ�� n �����ݵ�
  end
end
fprintf('NUMBER OF CLUSTERS: %i \n', NCLUST);

%���������ݵ����,����ordrho��nneigh
disp('assignation');
for i=1:N
  if (cl(ordrho(i))==-1)
    cl(ordrho(i))=cl(nneigh(ordrho(i)));
  end
end

%����cluster_core��cluster_halo
for i=1:N
  halo(i)=cl(i);
end 
if (NCLUST>1)
  % ��ʼ������ border_rho Ϊ 0,ÿ�� cluster ����һ�� border_rho ֵ
  for i=1:NCLUST
    border_rho(i)=0;
  end
  % ��ȡÿһ�� cluster ��ƽ���ܶȵ�һ���� border_rho
  for i=1:N-1
    for j=i+1:N
      % �����㹻С��������ͬһ�� cluster �� i �� j
      if ((cl(i)~=cl(j))&& (dist(i,j)<=dc))
        rho_aver=(rho(i)+rho(j))/2.; %% ȡ i,j �����ƽ���ֲ��ܶ�
        if (rho_aver>border_rho(cl(i)))
          border_rho(cl(i))=rho_aver;
        end
        if (rho_aver>border_rho(cl(j)))
          border_rho(cl(j))=rho_aver;
        end
      end
    end
  end
  % halo ֵΪ 0 ��ʾΪ outlier(��Ⱥ��)
  for i=1:N
    if (rho(i)<border_rho(cl(i)))
      halo(i)=0;
    end
  end 
end

%��һ����ÿ�� cluster
for i=1:NCLUST
  nc=0; %% �����ۼƵ�ǰ cluster �����ݵ�ĸ���
  nh=0; %% �����ۼƵ�ǰ cluster �к������ݵ�ĸ���
  for j=1:N
    if (cl(j)==i)
      nc=nc+1;
    end
    if (halo(j)==i)
      nh=nh+1;       %��Ⱥ���haloΪ0
    end
  end
  fprintf('CLUSTER: %i CENTER: %i ELEMENTS: %i CORE: %i HALO: %i \n', i,icl(i),nc,nh,nc-nh); 
end