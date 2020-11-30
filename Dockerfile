ARG MUGGLE_TAG=f7fb6146d8712c4bffb024f4d4f40c40ffab5598
FROM subugoe/muggle-buildtime-onbuild:${MUGGLE_TAG} as buildtime
FROM subugoe/muggle-runtime-onbuild:${MUGGLE_TAG} as runtime
CMD shinycaas::shiny_opts_az(); metacheck::runMetacheck()
