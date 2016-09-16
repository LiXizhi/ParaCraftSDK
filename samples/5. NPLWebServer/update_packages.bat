REM  author: LiXizhi
REM  date: 2016.9.14
if not exist "npl_packages" ( mkdir npl_packages )

pushd "npl_packages"

if exist "main\README.md" (

    pushd main
    git pull
    popd

) else (

    git clone https://github.com/NPLPackages/main

)

popd
