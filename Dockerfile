# Use an intermediate image to build megahit
FROM debian:bookworm-slim AS builder

RUN apt-get update && \
   apt-get install -y git make gcc zlib1g-dev cmake g++ 


RUN git clone https://github.com/voutcn/megahit && \
   \    
  cd megahit && \
  mkdir build && \
  cd build && \
  cmake ../ && \
  make  && \
  for LIB in $(ldd megahit_core | awk '{if (match($3,"/")){ print $3 }}'); do  LIB_NAME=$(basename "$LIB") cp "$LIB" "./$LIB_NAME"; done && \
  mkdir -p /data


# Use a the latest ubuntu image because megahit for now instead of a distroless image python dependencies until 2029 
FROM debian:bookworm-slim
RUN apt-get update && \
   apt-get install -y python3 libgomp1 
# Copy the megahit binary from the builder image
COPY --from=builder /megahit/build/megahit /bin/megahit
COPY --from=builder /megahit/build/megahit_core /bin/megahit_core
COPY --from=builder /megahit/build/megahit_core_no_hw_accel /bin/megahit_core_no_hw_accel
COPY --from=builder /megahit/build/megahit_core_no_hw_accel /bin/megahit_toolkit
COPY --from=builder /megahit/build/megahit_core_popcnt /bin/megahit_core_popcnt

# Set the entrypoint

ENTRYPOINT ["/bin/megahit"]
