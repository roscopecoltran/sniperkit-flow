FROM scratch
LABEL maintainer "Michalski Luc <michalski.luc@gmail.com>"

EXPOSE 80 443 2015 3000 

COPY ./dist/linux/redzilla_linux_adm64 /redzilla

ENTRYPOINT [ "/redzilla" ]
