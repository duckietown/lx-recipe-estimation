# LX Recipe: Estimation (`lx-estimation`)

This recipe builds the images used by the [lx-estimation](https://github.com/duckietown/lx-estimation)
Learning Experience (Kalman filter, particle filter and a histogram lane filter running on the Duckiebot).

It targets ROS 2 (Jazzy, `rmw_zenoh_cpp`) on the `ente` distribution:

- the **workbench image** (`Dockerfile`) is based on `dt-ros2-commons`; it compiles the LX's `packages/`
  with `colcon` and runs `launchers/default.sh`, i.e.
  `ros2 launch histogram_lane_filter histogram_lane_filter_node.launch.py veh:=ROBOT`;
- the **editor image** (`Dockerfile.vscode`) is based on `dt-vscode` with ROS 2 Jazzy and the compiled
  `duckietown_msgs` added, so that the notebooks and the integrated terminal can talk to the robot
  (`ros2 topic ...`, `ros2 param ...`, the `lx_ros2_tools` notebook panels).

There is no remote desktop any more: everything the student needs (parameter sliders, live images and
plots) is provided by the notebook panels in `packages/lx_ros2_tools`.

## Layout

```
Dockerfile                      workbench image (base: dt-ros2-commons), only the 3 ARGs at the top are specific
Dockerfile.vscode               editor image (base: dt-vscode + ROS 2 Jazzy), same 3 ARGs
dependencies-apt.txt            apt deps of the workbench image
dependencies-apt.vscode.txt     apt deps of the editor image (ROS 2 Jazzy packages)
dependencies-py3.txt            pip deps of both images (lib-dt-computer-vision, lib-dt-state-estimation, panels)
launchers/default.sh            `ros2 launch` of the student node
packages/lx_ros2_tools/         shared helpers: RosSession, panels, LiveParams, image conversion, robot params
assets/vscode/                  editor setup hooks
assets/duckiematrix/            Duckiematrix map used by `dts code start_matrix` (see settings.yaml)
```

The student node lives in the LX repository (`packages/histogram_lane_filter`); it is an `ament_python`
package that is compiled into the workbench image together with the recipe packages.

## Dependencies

Specify any `apt` or `python` dependencies needed in
[dependencies-apt.txt](./dependencies-apt.txt) / [dependencies-apt.vscode.txt](./dependencies-apt.vscode.txt)
and [dependencies-py3.txt](./dependencies-py3.txt). The images run Python 3.12; pin only what must be pinned.

`dependencies-py3.txt` must keep `ipywidgets`, `ipympl` and `matplotlib`: they are needed by the notebook
panels (`lx_ros2_tools.panel`).

## Robot stack

The histogram lane filter node detects and ground-projects the line segments itself from the camera
images, so it only needs the ROS 2 robot stack (`dts stack up -H ROBOT ros2/duckiebot`: camera, wheel
encoders, wheels driver). The `ros2-core/default` stack (lane following demo) is not required.

## Duckiematrix

By default, each LX is compatible with the [Duckiematrix](https://docs.duckietown.com/ente/devmanual-duckiematrix/intro.html).
See the [README in the LX template](https://github.com/duckietown/template-lx/blob/ente/README.md)
for more details on how to deploy this capability through the `dts code` API.
You can define the exact configuration of the Duckiematrix environment in the
[assets/duckiematrix](./assets/duckiematrix) directory. For more details see
[the Duckiematrix manual](https://docs.duckietown.com/ente/devmanual-duckiematrix/intro.html).

## Building locally

```
docker buildx build --load -f Dockerfile --build-context recipe=. --build-context meat=/path/to/lx-estimation \
  --build-arg ARCH=arm64v8 --build-arg DISTRO=ente -t lx-estimation:test .
```

The same command with `-f Dockerfile.vscode` builds the editor image.
