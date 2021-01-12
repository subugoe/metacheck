ARG MUGGLE_TAG=0.1.0-3
FROM subugoe/muggle-buildtime-onbuild:${MUGGLE_TAG} as buildtime
FROM subugoe/muggle-runtime-onbuild:${MUGGLE_TAG} as runtime
CMD shinycaas::shiny_opts_az(); metacheck::runMetacheck()
