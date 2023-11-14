# VRoidHubWebAPIforGodot
 GodotEngineでVRoidHubWebAPIを使ったサンプル

 使用したプラグイン 
  VRM Importer for 3D Avatars and MToon Shader : https://godotengine.org/asset-library/asset/2031

  動作
  https://youtu.be/u7l-A3Ub1rQ

Change Log v1
今回からaddonsフォルダーは削除しています。使用する前にAssetLibからgodot-vrmをダウンロードしてください。上記の使用したプラグインというやつです。
ボーンの関係上VRM1.0は非対応にしました。
モデルをロードした後になぜかモデルが暗くなるためDirectionalLight3Dを設置しています。オンオフは親ノードであるModelLoaderのインスペクター中の Model Lightを切り替えてください。
アニメーションテスト用のボタンを追加しました。
容量制限に引っかかったためandroidフォルダーを削除しました。Android用にビルドする際はAndroidエクスポートテンプレートをインストールし、Androidフォルダ内のpluginsフォルダに以下のファイルを入れてください。

ClipBoardPlugin : https://astralmemory.net:8081/share.cgi?ssid=f268951da719438694f5dcb23b1edf06