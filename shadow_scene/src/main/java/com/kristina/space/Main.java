//package com.kristina.space;(^_-)
//import javafx.application.Application;import java

package com.kristina.space;

import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.Headers;

import java.io.*;
import java.net.InetSocketAddress;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.awt.Desktop;

public class Main {

    public static void main(String[] args) throws IOException {
        // Создаём HTTP-сервер на порту 8080
        HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);

        // Обработчик для корневого пути и всех подпутей
        server.createContext("/", new StaticFileHandler());

        server.setExecutor(null); // используем стандартный Executor
        server.start();

        System.out.println("Сервер запущен на http://localhost:8080");
        System.out.println("Для доступа извне используйте ngrok: ngrok http 8080");

        // Открываем браузер автоматически
        if (Desktop.isDesktopSupported()) {
            Desktop.getDesktop().browse(URI.create("http://localhost:8080"));
        }

        // Ждём нажатия Enter для завершения
        System.out.println("Нажмите Enter для остановки сервера...");
        try {
            System.in.read();
        } catch (IOException ignored) {
        }

        server.stop(0);
        System.out.println("Сервер остановлен.");
    }

    // Простой обработчик статических файлов из ресурсов /web
    static class StaticFileHandler implements HttpHandler {
        @Override
        public void handle(com.sun.net.httpserver.HttpExchange exchange) throws IOException {
            String path = exchange.getRequestURI().getPath();
            if (path.equals("/")) {
                path = "/index.html";
            }

            // Ищем файл в ресурсах (папка web)
            InputStream is = getClass().getResourceAsStream("/web" + path);
            if (is == null) {
                // Если файл не найден, отдаём 404
                String response = "404 Not Found";
                exchange.sendResponseHeaders(404, response.length());
                OutputStream os = exchange.getResponseBody();
                os.write(response.getBytes(StandardCharsets.UTF_8));
                os.close();
                return;
            }

            // Определяем MIME-тип
            String mime = "text/plain";
            if (path.endsWith(".html")) mime = "text/html";
            else if (path.endsWith(".css")) mime = "text/css";
            else if (path.endsWith(".js")) mime = "application/javascript";
            else if (path.endsWith(".png")) mime = "image/png";
            else if (path.endsWith(".jpg") || path.endsWith(".jpeg")) mime = "image/jpeg";

            Headers headers = exchange.getResponseHeaders();
            headers.set("Content-Type", mime);

            // Читаем файл и отправляем
            byte[] data = is.readAllBytes();
            exchange.sendResponseHeaders(200, data.length);
            OutputStream os = exchange.getResponseBody();
            os.write(data);
            os.close();
            is.close();
        }
    }
}