import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { SummaryPipe } from './pipes/summary.pipe';
import { BlogComponent } from './components/blog/blog/blog.component';
import { BlogCardComponent } from './components/blog/blog-card/blog-card.component';
import { BlogEditComponent } from './components/blog/blog-edit/blog-edit.component';
import { BlogsComponent } from './components/blog/blogs/blogs.component';
import { FamousBlogsComponent } from './components/blog/famous-blogs/famous-blogs.component';
import { CommentBoxComponent } from './components/comment/comment-box/comment-box.component';
import { CommentSystemComponent } from './components/comment/comment-system/comment-system.component';
import { CommentsComponent } from './components/comment/comments/comments.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { HomeComponent } from './components/home/home.component';
import { LoginComponent } from './components/login/login.component';
import { NavbarComponent } from './components/navbar/navbar.component';
import { NotFoundComponent } from './components/not-found/not-found.component';
import { PhotoAlbumComponent } from './components/photo-album/photo-album.component';
import { RegisterComponent } from './components/register/register.component';

@NgModule({
  declarations: [
    AppComponent,
    SummaryPipe,
    BlogComponent,
    BlogCardComponent,
    BlogEditComponent,
    BlogsComponent,
    FamousBlogsComponent,
    CommentBoxComponent,
    CommentSystemComponent,
    CommentsComponent,
    DashboardComponent,
    HomeComponent,
    LoginComponent,
    NavbarComponent,
    NotFoundComponent,
    PhotoAlbumComponent,
    RegisterComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    BrowserAnimationsModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
