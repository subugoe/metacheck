ARG MUGGLE_TAG=0.1.2-20211124
FROM subugoe/muggle-buildtime-onbuild:${MUGGLE_TAG} as buildtime
FROM subugoe/muggle-runtime-onbuild:${MUGGLE_TAG} as runtime
ENV R_FUTURE_PLAN=multicore
CMD shinycaas::shiny_opts_az(); metacheck::runMetacheck()
