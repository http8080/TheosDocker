docker compose build

# # nic.pl
# docker run -it --rm -v $(pwd):/src --workdir /src theos-builder nic.pl
# # make package
# docker run -it --rm -v $(pwd):/src --workdir /src theos-builder make package
# # make package FINALPACKAGE=1
# docker run -it --rm -v $(pwd):/src --workdir /src tweak-builder make package FINALPACKAGE=1