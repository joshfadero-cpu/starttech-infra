# ------------------------------------------------------------------
# ALB fronting the EKS worker nodes on a fixed NodePort
# ------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "starttech-alb-sg"
  description = "Allow HTTP from the internet to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere (CloudFront origin requests)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "starttech-alb-sg"
  }
}

# Allow the ALB to reach the workers on the NodePort
resource "aws_security_group_rule" "nodes_from_alb" {
  type                     = "ingress"
  description              = "NodePort traffic from the ALB"
  from_port                = var.node_port
  to_port                  = var.node_port
  protocol                 = "tcp"
  security_group_id        = var.eks_security_group_id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_lb" "backend" {
  name               = "starttech-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "backend" {
  name        = "starttech-backend-tg"
  port        = var.node_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_autoscaling_attachment" "backend_nodes" {
  autoscaling_group_name = var.node_asg_name
  lb_target_group_arn    = aws_lb_target_group.backend.arn
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}
