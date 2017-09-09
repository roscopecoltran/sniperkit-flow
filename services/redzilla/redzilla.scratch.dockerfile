FROM scratch

EXPOSE 80 443 2015 3000 

COPY ./redzilla /redzilla

ENTRYPOINT [ "/redzilla" ]
