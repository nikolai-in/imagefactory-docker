# syntax=docker/dockerfile:1
FROM fedora:rawhide as Build

RUN dnf install -by imagefactory

CMD ["sh"]