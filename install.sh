DOCKERBASEIMAGE=$(echo $DOCKERIMAGE | cut -d ':' -sf1)
DOCKERIMAGETAG=$(echo $DOCKERIMAGE | cut -d ':' -sf2)
if [ ! -z "$DOCKERIMAGETAG" ]
then
    mkdir -p $DOCKERIMAGE
    sed "s|@BASE_IMAGE@|practicalci/${DOCKERBASEIMAGE}|" $DOCKERIMAGETAG/Dockerfile.in > $DOCKERIMAGE/Dockerfile
fi
docker build -t practicalci/$DOCKERIMAGE -f $DOCKERIMAGE/Dockerfile --no-cache .

