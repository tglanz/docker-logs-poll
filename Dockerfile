FROM debian

COPY ./image-scripts/ /image/scripts/

RUN chmod -R 777 /image/scripts

ENTRYPOINT [ "/image/scripts/entrypoint.sh" ]
