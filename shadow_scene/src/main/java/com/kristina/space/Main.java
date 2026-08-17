//package com.kristina.space;(^_-)
//import javafx.application.Application;import java

package com.kristina.space;
import javafx.application.Application;import javafx.fxml.FXMLLoader;import javafx.scene.Parent;import javafx.scene.Scene;import javafx.scene.PerspectiveCamera;import javafx.scene.SceneAntialiasing;import javafx.scene.AmbientLight;import javafx.scene.PointLight;import javafx.scene.paint.Color;import javafx.scene.layout.StackPane;import javafx.scene.shape.Sphere;import javafx.stage.Stage;
public class Main extends Application {
    @Override
    public void start(Stage stage) throws Exception {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("/scene.fxml"));
        Parent root = loader.load();
        
        StackPane rootPane = (StackPane) loader.getNamespace().get("rootPane");
        Sphere sphere = (Sphere) loader.getNamespace().get("spaceSphere");
        
        PerspectiveCamera camera = new PerspectiveCamera(true);
        camera.setNearClip(0.1);
        camera.setFarClip(1000.0);
        camera.setTranslateZ(-800);
        
        AmbientLight ambient = new AmbientLight(Color.web("#050515"));
        
        PointLight light = new PointLight(Color.WHITE);
        double angle = Math.toRadians(30);
        light.setTranslateX(Math.sin(angle) * 500);
        light.setTranslateY(Math.cos(angle) * -500);
        light.setTranslateZ(-300);
        
        rootPane.getChildren().addAll(camera, ambient, light);
        
        Scene scene = new Scene(root, 800, 600, true, SceneAntialiasing.BALANCED);
        scene.setCamera(camera);
        
        stage.setTitle("Схема света и тени 30 градусов");
        stage.setScene(scene);
        stage.show();
    }

    @Override
    public void stop() {
        System.out.println("Симуляция остановлена. Ресурсы полностью уничтожены.");
    }

    public static void main(String[] args) {
        launch(args);
    }
}