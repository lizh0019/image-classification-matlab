function fastclassify(root,dataset)
%% classify
initialization

load Hist_test

TBTsum=single(sum(Hist(:,112:1111),2)+eps);
Hist=bsxfun(@rdivide, Hist(:,112:1111), TBTsum);

Pathname=strcat(root,dataset,'\');%'D:\databases\101_ObjectCategories\'
Category=dir(strcat(Pathname,'*.*'));%read the database
CategoryNum=17;
%obtain offset
offset=[0];

for Ii=1:CategoryNum,
    categoryimgnum=0;
    if (Category(Ii).isdir==1 && ~strcmp(Category(Ii).name,'.') && ~strcmp(Category(Ii).name,'..')), 
        foldername=Category(Ii).name;
        Image=dir(strcat(Pathname,foldername,'\*.jpg'));
        categoryimgnum=categoryimgnum+100;%length(Image);
        offset=[offset,offset(end)+categoryimgnum];
    end
end

yapp = zeros(offset(end),1);
for i=1:CategoryNum-2,
    pos=offset(i+1);
    yapp(offset(i)+1:pos) = i; 
end






fid=fopen('Sparse_Hist_Test.txt', 'wt');
for i=1:size(yapp),
    fprintf(fid, '%d ', yapp(i));
    for j=1:size(Hist,2),
        if Hist(i,j)~=0,
            fprintf(fid, '%s %f ',strcat(num2str(j),':'),Hist(i,j));
        end
    end
    fprintf(fid, '\n');
end
fclose(fid)

!predict.exe Sparse_Hist_Test.txt CVM.model.txt CVM.output.txt


fid = fopen('CVM.output.txt', 'r');
ypred= fscanf(fid,'%d');
fclose(fid);

CategoryNum=length(offset)-1;
Confusion.matrix=zeros(CategoryNum,CategoryNum);
Confusion.name={};imgnum=0;accuracy=0;
for Ii=1:CategoryNum+2,
    if (Category(Ii).isdir==1 && ~strcmp(Category(Ii).name,'.') && ~strcmp(Category(Ii).name,'..')), 
        foldername=Category(Ii).name;Confusion.name{Ii-2}=foldername;
        Image=dir(strcat(Pathname,foldername,'\*.jpg'));
        categoryimgnum=0;
        for k=1:length(Image),
            enquiry=strcat(Pathname,foldername,'\',Image(k).name);

            imgnum=imgnum+1;
            categoryimgnum=categoryimgnum+1;
            Confusion.matrix(Ii-2,ypred(imgnum))=Confusion.matrix(Ii-2,ypred(imgnum))+1;
            Result=Category(ypred(imgnum)+2).name;
            result=strcmp(foldername,Result);
            accuracy=accuracy+result;

            if categoryimgnum==100, break; end
        end
    end
end
save Confusion Confusion
Matrix=Confusion.matrix;
matrix=Matrix./repmat(sum(Matrix,2),1,CategoryNum);
diagmatrix=diag(matrix);
[score,index]=sort(diagmatrix,'descend');
for i=1:CategoryNum,Confusion.name{index(i)},score(i),end
accuracy0=accuracy/imgnum
accuracy1=mean(diagmatrix(1:CategoryNum))

display(strcat(num2str(imgnum), ' test images classified'))














