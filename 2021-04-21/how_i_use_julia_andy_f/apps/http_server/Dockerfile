FROM julia

WORKDIR /app

COPY . /app

RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'

EXPOSE 8081
CMD julia --project=. serve.jl